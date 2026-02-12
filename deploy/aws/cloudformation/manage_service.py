import argparse
import sys

import boto3
from botocore.exceptions import ClientError, WaiterError


class PIIEraserService:
    def __init__(self, stack_name: str, region: str):
        self.cf = boto3.client("cloudformation", region_name=region)
        self.ecs = boto3.client("ecs", region_name=region)
        self.app_scaling = boto3.client("application-autoscaling", region_name=region)
        self.cluster = None
        self.service = None
        self._discover_resources(stack_name)

    def _discover_resources(self, stack_name: str):
        """Finds ECS Service and Cluster physical IDs by scanning nested stacks."""
        try:
            # Get all resources in the main stack
            main_resources = self.cf.describe_stack_resources(StackName=stack_name)["StackResources"]

            # Filter for nested stacks
            nested_stacks = [r["PhysicalResourceId"] for r in main_resources if r["ResourceType"] == "AWS::CloudFormation::Stack"]

            for nested_stack_id in nested_stacks:
                # Scan resources inside each nested stack
                nested_res = self.cf.describe_stack_resources(StackName=nested_stack_id)["StackResources"]
                for r in nested_res:
                    if r["ResourceType"] == "AWS::ECS::Service":
                        self.service = r["PhysicalResourceId"]
                    elif r["ResourceType"] == "AWS::ECS::Cluster":
                        self.cluster = r["PhysicalResourceId"]

                if self.service and self.cluster:
                    break

            if not self.service or not self.cluster:
                raise ValueError("Could not find ECS Service or Cluster in the specified stack.")

        except ClientError as e:
            print(f"❌ AWS Error: {e}")
            sys.exit(1)

    def get_status(self):
        resp = self.ecs.describe_services(cluster=self.cluster, services=[self.service])
        s = resp["services"][0]
        print(f"Status:  {s['status']}")
        print(f"Desired: {s['desiredCount']}")
        print(f"Running: {s['runningCount']}")
        print(f"Pending: {s['pendingCount']}")

    def print_recent_events(self):
        """Prints the last few service events to help diagnose issues."""
        try:
            resp = self.ecs.describe_services(cluster=self.cluster, services=[self.service])
            events = resp["services"][0].get("events", [])
            print("\n🔍 Recent ECS Service Events:")
            for e in events[:10]:
                print(f"  • {e['createdAt'].strftime('%H:%M:%S')}: {e['message']}")
        except Exception as e:
            print(f"  (Failed to retrieve events: {e})")

    def _get_app_autoscaling_resource_id(self):
        """
        Parses the ECS Service ARN to get the ResourceId required by Application Auto Scaling.
        Format: service/clusterName/serviceName
        """
        if self.service and "service/" in self.service:
            # ARN format: arn:aws:ecs:region:account:service/cluster-name/service-name
            # We want the last part: service/cluster-name/service-name
            return self.service.split(":")[-1]
        return None

    def _toggle_auto_scaling(self, suspended: bool):
        resource_id = self._get_app_autoscaling_resource_id()
        if not resource_id:
            return

        action = "🚫 Suspending" if suspended else "✅ Resuming"
        print(f"{action} Application Auto Scaling...")

        self.app_scaling.register_scalable_target(
            ServiceNamespace="ecs",
            ResourceId=resource_id,
            ScalableDimension="ecs:service:DesiredCount",
            SuspendedState={
                "DynamicScalingInSuspended": suspended,
                "DynamicScalingOutSuspended": suspended,
                "ScheduledScalingSuspended": suspended,
            },
        )

    def scale(self, count: int, wait: bool = True):
        assert count >= 0, f"count value {count} invalid: it must be greater or equal to 0"

        # Suspend autoscaler to prevent stale alarms from waking the service
        self._toggle_auto_scaling(suspended=(count == 0))

        print(f"🔄 Scaling service to {count}...")
        self.ecs.update_service(cluster=self.cluster, service=self.service, desiredCount=count)

        if wait:
            print("⏳ Waiting for action to complete (Ctrl+C to skip)...")
            try:
                waiter = self.ecs.get_waiter("services_stable")
                waiter.wait(cluster=self.cluster, services=[self.service], WaiterConfig={"Delay": 5, "MaxAttempts": 60})
                print("✅ Service is ready!")
            except KeyboardInterrupt:
                print("\n⚠️  Wait interrupted by user. Service update continues in background.")
            except WaiterError as e:
                print("\n❌ Service did not stabilize within the timeout.")
                self.print_recent_events()
                raise RuntimeError("ECS Service failed to stabilize. Check the events above for capacity or configuration errors.") from e
        else:
            print("🚀 Request sent (async), skipping wait.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="PII Eraser: Scale to Zero Manager")
    parser.add_argument("action", choices=["start", "stop", "status"], help="Action to perform")
    parser.add_argument("--count", type=int, default=1, help="Target instance count (start only)")
    parser.add_argument("--region", help="AWS Region")
    parser.add_argument("--stack", default="pii-eraser-stack", help="CloudFormation Stack Name")
    parser.add_argument("--no-wait", action="store_true", help="Don't wait for stability")

    args = parser.parse_args()

    svc = PIIEraserService(args.stack, args.region)

    if args.action == "status":
        svc.get_status()
    elif args.action == "stop":
        svc.scale(0, wait=not args.no_wait)
    elif args.action == "start":
        svc.scale(args.count, wait=not args.no_wait)
