package com.sample.company;

import org.springframework.stereotype.Component;

import com.company.employees.Body;
import com.company.employees.Message;
import com.schemas.EmployeeDetails;

@Component("mapper")
public class Mapper {

    public EmployeeDetails mapCompanyDetails(Message xmlMessage) {
        Body body = xmlMessage.getBody();
        EmployeeDetails employeeDetails = EmployeeDetails.newBuilder()
                .setEmployeeId(body.getEmpId())
                .setFirstName(body.getFirstName())
                .setLastName(body.getLastName())
                .setEmail(body.getEmail())
                .setPhoneNumber(body.getPhone())
                .setDateOfBirth(body.getDateOfBirth())
                .setGender(body.getGender())
                .setHireDate(body.getHireDate())
                .setSalary(body.getSalary())
                .setBonus(body.getBonus())
                .setMarried(body.isMarried())
                .setCity(body.getCity())
            .build();
        return employeeDetails;
    }
}
