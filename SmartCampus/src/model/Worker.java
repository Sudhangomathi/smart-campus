package model;

public class Worker {
    private int workerId; // references user_id
    private String name;
    private String phoneNo;
    private String specialization;
    private String status; // available, busy
    private String email; // derived from users table

    public Worker() {}

    public Worker(int workerId, String name, String phoneNo, String specialization, String status) {
        this.workerId = workerId;
        this.name = name;
        this.phoneNo = phoneNo;
        this.specialization = specialization;
        this.status = status;
    }

    public int getWorkerId() {
        return workerId;
    }

    public void setWorkerId(int workerId) {
        this.workerId = workerId;
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

    public String getSpecialization() {
        return specialization;
    }

    public void setSpecialization(String specialization) {
        this.specialization = specialization;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }
}
