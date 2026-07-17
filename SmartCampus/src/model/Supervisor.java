package model;

public class Supervisor {
    private int supervisorId; // references user_id
    private String name;
    private String phoneNo;
    private String department;
    private String email; // derived from users table

    public Supervisor() {}

    public Supervisor(int supervisorId, String name, String phoneNo, String department) {
        this.supervisorId = supervisorId;
        this.name = name;
        this.phoneNo = phoneNo;
        this.department = department;
    }

    public int getSupervisorId() {
        return supervisorId;
    }

    public void setSupervisorId(int supervisorId) {
        this.supervisorId = supervisorId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPhoneNo() {
        return phoneNo;
    }

    public void setPhoneNo(String phoneNo) {
        this.phoneNo = phoneNo;
    }

    public String getDepartment() {
        return department;
    }

    public void setDepartment(String department) {
        this.department = department;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }
}
