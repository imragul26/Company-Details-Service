package com.sample.company;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.apache.camel.CamelContext;
import org.apache.camel.EndpointInject;
import org.apache.camel.Exchange;
import org.apache.camel.ProducerTemplate;
import org.apache.camel.builder.AdviceWith;
import org.apache.camel.component.mock.MockEndpoint;
import org.apache.camel.test.spring.junit5.CamelSpringBootTest;
import org.apache.camel.test.spring.junit5.EnableRouteCoverage;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.kafka.test.context.EmbeddedKafka;
import org.springframework.test.annotation.DirtiesContext;
import org.springframework.test.annotation.DirtiesContext.ClassMode;

import com.schemas.EmployeeDetails;

@EmbeddedKafka(partitions = 1, brokerProperties = { "listener=PLAINTEXT://localhost:9092",
		"port=9092" }, kraft = false, topics = { "${kafka.topic}" })
@SpringBootTest(classes = CompanyApplication.class)
@CamelSpringBootTest
@EnableRouteCoverage
@EnableAutoConfiguration
@DirtiesContext(classMode = ClassMode.AFTER_EACH_TEST_METHOD)
class CompanyApplicationTests {

	@Autowired
	private CamelContext camelContext;

	@Autowired
	private ProducerTemplate producerTemplate;

	@EndpointInject("mock:kafka")
	protected MockEndpoint kafka;

	@EndpointInject("mock:jms:dlq")
	protected MockEndpoint dlq;

	@Value("activemq:queue")
	String queue;

	@Test
	public void contextLoads() throws Exception {
		AdviceWith.adviceWith(this.camelContext, "activeMQToKafka", (r) -> {
			r.replaceFromWith("direct:start");
			r.weaveByToUri("jms:*").replace().to(this.dlq);
			r.weaveByToUri("kafka:*").replace().to(this.kafka);
		});
		this.kafka.expectedMessageCount(1);
		this.producerTemplate.sendBody("direct:start",
				this.getClass().getClassLoader().getResourceAsStream("company.xml"));
		EmployeeDetails avro = (EmployeeDetails) ((Exchange) this.kafka.getExchanges().get(0))
				.getIn()
				.getBody(EmployeeDetails.class);

		assertEquals("Jane", avro.getFirstName());
		assertEquals("Smith", avro.getLastName());
		assertEquals("jane.smith@example.com", avro.getEmail());

		this.kafka.assertIsSatisfied();
		this.kafka.reset();

	}

	@Test
	public void checkunitTestReports() throws Exception {
		AdviceWith.adviceWith(this.camelContext, "activeMQToKafka", (r) -> {
			r.replaceFromWith("direct:start");
			r.weaveByToUri("jms:*").replace().to(this.dlq);
			r.weaveByToUri("kafka:*").replace().to(this.kafka);
		});
		this.kafka.expectedMessageCount(1);
		this.producerTemplate.sendBody("direct:start",
				this.getClass().getClassLoader().getResourceAsStream("company.xml"));
		EmployeeDetails avro = (EmployeeDetails) ((Exchange) this.kafka.getExchanges().get(0))
				.getIn()
				.getBody(EmployeeDetails.class);

		assertEquals("Jane", avro.getFirstName());
		assertEquals("Smith", avro.getLastName());
		assertEquals("jane.smith@example.com", avro.getEmail());

		this.kafka.assertIsSatisfied();
		this.kafka.reset();

	}

}
