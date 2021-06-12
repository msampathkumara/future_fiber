package com.Errors;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import org.json.JSONObject;

public class ServerError {

    String code;
    String errno;
    String sqlState;
    String sqlMessage;

    public static ServerError getError(JSONObject jsonObject) throws JsonProcessingException {

        ObjectMapper m = new ObjectMapper();

        ServerError myClass = m.readValue(jsonObject.toString(), ServerError.class);
        if (myClass.getErrno() == 1) {
            return m.readValue(jsonObject.toString(), ServerError.class);
        }


        return null;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public int getErrno() {
        return Integer.parseInt(errno);
    }

    public void setErrno(String errno) {
        this.errno = errno;
    }

    public String getSqlState() {
        return sqlState;
    }

    public void setSqlState(String sqlState) {
        this.sqlState = sqlState;
    }

    public String getSqlMessage() {
        return sqlMessage;
    }

    public void setSqlMessage(String sqlMessage) {
        this.sqlMessage = sqlMessage;
    }
}
