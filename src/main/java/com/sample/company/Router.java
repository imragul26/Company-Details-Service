package com.sample.company;

import org.apache.avro.AvroTypeException;
import org.apache.camel.CamelContext;
import org.apache.camel.Exchange;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.component.kafka.KafkaConstants;
import org.apache.camel.support.processor.validation.SchemaValidationException;
import org.apache.kafka.common.errors.SerializationException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import jakarta.xml.bind.UnmarshalException;

@Component
public class Router extends RouteBuilder {

    @Autowired
    private CamelContext camelContext;

    @Value("${activemq.queue}")
    private String queue;

    @Value("${kafka.topic}")
    private String topic;

    @Value("${activemq.dlqueue}")
    private String dlqueue;

    // company_kafka_topic
    // activemq_company_queue

    @Override
    public void configure() throws Exception {

        onException(SchemaValidationException.class, UnmarshalException.class)
                .to("log:company-detail?level=ERROR&showCaughtException=true&showHeaders=true")
                .setHeader(Exchange.EXCEPTION_CAUGHT, simple("${exception.message}"))
                .handled(true)
                .useOriginalMessage()
                .to("jms:queue:" + dlqueue)
                .end();

        onException(AvroTypeException.class, SerializationException.class)
                .to("log:company-detail?level=ERROR&showCaughtException=true&showHeaders=true")
                .setHeader(Exchange.EXCEPTION_CAUGHT, simple("${exception.message}"))
                .handled(true)
                .useOriginalMessage()
                .to("jms:queue:" + dlqueue)
                .end();

        from("jms:queue:" + queue)
                .routeId("activeMQToKafka")
                .transacted()
                .removeHeaders("*", Exchange.BREADCRUMB_ID)
                .to("log:com.sample.company?level=DEBUG&showall=true")
                .unmarshal().jaxb()
                .to("validator:xsd/company.xsd")
                .transform().method("mapper", "mapCompanyDetails")
                .setHeader(KafkaConstants.KEY, simple("${body.getEmployeeId}"))
                .setHeader("eventCreationTimestamp", simple("${date-with-timezone:now:UTC:yyyy-MM-dd'T'HH:mm:SSSX}"))
                .to("log:kafka-log?level=INFO&showHeaders=true")
                .to("kafka:"+topic+"?additionalProperties.value.subject.name.strategy=io.confluent.kafka.serializers.subject.TopicRecordNameStrategy");

    }

}
