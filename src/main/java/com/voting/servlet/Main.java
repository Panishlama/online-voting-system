package com.voting;

import org.apache.catalina.Context;
import org.apache.catalina.LifecycleException;
import org.apache.catalina.startup.Tomcat;

import java.io.File;

public class Main {
    public static void main(String[] args) throws LifecycleException {
        Tomcat tomcat = new Tomcat();
        int port = Integer.parseInt(System.getenv().getOrDefault("PORT", "8080"));
        tomcat.setPort(port);

        String webappDir = new File("src/main/webapp").getAbsolutePath();
        Context context = tomcat.addWebapp("/", webappDir);

        tomcat.start();
        System.out.println("Tomcat 10 started on port: " + port);
        tomcat.getServer().await();
    }
}