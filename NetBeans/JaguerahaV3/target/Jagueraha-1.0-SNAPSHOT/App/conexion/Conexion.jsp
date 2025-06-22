<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="java.io.*" %>

<%
    Connection conn = null;

    Class.forName("org.postgresql.Driver");
    conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/Jagueraha", "postgres", "admin");
    if (conn != null) {
       
    }else{
        out.print("Error al conectarse");
    }
%>
