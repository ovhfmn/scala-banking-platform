#!/bin/sh

echo "Waiting for Redpanda to be ready..."
until rpk cluster info --brokers redpanda:29092 > /dev/null 2>&1; do
	echo "Redpanda is still initializing... retrying in 2 seconds"
	sleep 1
done


echo "Redpanda is online. Creating banking topics..."
rpk topic create account-events --brokers redpanda:29092 -p 3 -r 1


echo "Infrastructure provisioning complete!"
