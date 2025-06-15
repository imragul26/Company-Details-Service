package com.sample.company;

import org.apache.activemq.ActiveMQConnectionFactory;
import org.messaginghub.pooled.jms.JmsPoolConnectionFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Scope;
import org.springframework.jms.connection.JmsTransactionManager;
import org.springframework.stereotype.Component;

import jakarta.jms.ConnectionFactory;

@Component
public class BeanConfig {

    @Value("${activemq.url}")
    private String activemqUrl;

    @Value("${activemq.username}")
    private String username;

    @Value("${activemq.password}")
    private String password;

    @Bean
    @Scope("singleton")
    public ConnectionFactory jmsConnectionFactory() {
        ActiveMQConnectionFactory activeMQConnectionFactory = new ActiveMQConnectionFactory(username, password,
                activemqUrl);
        activeMQConnectionFactory.setExclusiveConsumer(true);
        JmsPoolConnectionFactory jmsPoolConnectionFactory = new JmsPoolConnectionFactory();
        jmsPoolConnectionFactory.setConnectionFactory(activeMQConnectionFactory);
        return jmsPoolConnectionFactory;
    }

    @Bean("jta")
    public JmsTransactionManager jmsTransactionManger() {
        return new JmsTransactionManager(jmsConnectionFactory());
    }
}
