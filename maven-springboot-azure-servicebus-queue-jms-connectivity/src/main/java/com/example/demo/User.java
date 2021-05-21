package com.example.demo;

import java.io.Serializable;

import org.springframework.web.multipart.MultipartFile;

// Define a generic User class.
public class User implements Serializable {

    private static final long serialVersionUID = -295422703255886286L;

    private MultipartFile uploadfile;

    User(MultipartFile uploadfile) {
        setName(uploadfile);
    }

    public MultipartFile getName() {
        return uploadfile;
    }

    public void setName(MultipartFile uploadfile) {
        this.uploadfile = uploadfile;
    }

}