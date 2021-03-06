
Feeding JSON format data to a Kafka topic

Prerequisites: 
Before you start this procedure, ensure that you, 

Have administrative access to running Kafka cluster and that cluster must have connectivity as described in the loading Prerequisites.
Identify and note the ZooKeeper hostname and port.
Identify and note the hostname and port of the Kafka broker(s).
Identify and note the hostname and port of the Kafka Rest Proxy.
This procedure assumes that you have installed the Apache Kafka distribution. 
If you are using a different Kafka distribution, you may need to adjust certain commands in the procedure.
____________________________________________________________________________________________________________________________
Note:
	rest-proxy  localhost:8082
	zookeeper localhost:2182 
	bootstrap-server localhost:9095
_________________________________________________________________________________________________________________________________


Login to shell

	$ ssh 10.105.62.44

Move to Folder

	$ cd kafka_2.12-2.4.0

Get a list of topics

	$ curl "http://localhost:8082/topics"

Get info about one topic
	$ curl "http://localhost:8082/topics/<menction topic name>"
example: $ curl "http://localhost:8082/topics/topic-test-1"


To displays all the topics
	$ bin/kafka-topics.sh --list --zookeeper localhost:2182

Create a topic 
	$ bin/kafka-topics.sh --create --zookeeper localhost:2182 --replication-factor 1 --partitions 1 --topic topic-test-1

Create a json file
 	vi json-sample-data-1.json

To stream the contents of the sample-data-test-1.json file to a Kafka console producer

	$ bin/kafka-console-producer.sh \
	    --broker-list localhost:9095 \
	    --topic topic-test-1 < sample-json-data.json

To verify that the Kafka console producer published the messages to the topic by running a Kafka console consumer

	$ bin/kafka-console-consumer.sh \
	    --bootstrap-server localhost:9095 --topic topic-test-1 \
	    --from-beginning

Kafka REST Proxy 

The Kafka REST Proxy provides a RESTful interface to a Kafka cluster. It makes it easy to produce and consume messages, view the 
state of the cluster, and perform administrative actions without using the native Kafka protocol or clients. Examples of use cases
include reporting data to Kafka from any frontend app built in any language, ingesting messages into a stream processing framework
that doesn’t yet support Kafka, and scripting administrative actions.


Produce a message using JSON with the value '{ "month": 12}' to the topic topic-test-1

	$ curl -X POST -H "Content-Type: application/vnd.kafka.json.v2+json" \
	      -H "Accept: application/vnd.kafka.v2+json" \
	      --data '{"records":[{"value":{"month": 12}}]}' "http://localhost:8082/topics/topic-test-1"


Expected output from preceeding command

	  {
	   "offsets":[{"partition":0,"offset":0,"error_code":null,"error":null}],"key_schema_id":null,"value_schema_id":null
	  }


Create a consumer for JSON data, starting at the beginning of the topic's

	$ curl -X POST -H "Content-Type: application/vnd.kafka.v2+json" \
	      --data '{"name": "my_consumer_instance", "format": "json", "auto.offset.reset": "earliest"}' \
	      http://localhost:8082/consumers/my_json_consumer

Expected output from preceding command
	 {
	  "instance_id":"my_consumer_instance",
	  "base_uri":"http://localhost:8082/consumers/my_json_consumer/instances/my_consumer_instance"
	 }
Expected output from preceding command



log and subscribe to a topic. Then consume some data using the base URL in the first response.

	$ curl -X POST -H "Content-Type: application/vnd.kafka.v2+json" --data '{"topics":["topic-test-1"]}' \
	  http://localhost:8082/consumers/my_json_consumer/instances/my_consumer_instance/subscription

Expected output from preceding command
No content in response


	$ curl -X GET -H "Accept: application/vnd.kafka.json.v2+json" \
	      http://localhost:8082/consumers/my_json_consumer/instances/my_consumer_instance/records

Expected output from preceding command

	[
	{"key":null,"value":{"month":12},"partition":0,"offset":0,"topic":"topic-test-1"}
	]

Finally, close the consumer with a DELETE to make it leave the group and clean up it's resources.

	$ curl -X DELETE -H "Content-Type: application/vnd.kafka.v2+json" \
	      http://localhost:8082/consumers/my_json_consumer/instances/my_consumer_instance
	      
No content in response



