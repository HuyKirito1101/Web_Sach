<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <c:if test="${not empty _csrf}">
        <meta name="csrf-token" content="<c:out value='${_csrf.token}'/>">
        <meta name="csrf-parameter" content="<c:out value='${_csrf.parameterName}'/>">
    </c:if>
    <title><c:out value="${title != null ? title : 'Quản Lý Chuỗi Cửa Hàng Sách Cũ'}"/></title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-T3c6CoIi6uLrA9TneNEoa7RxnatzjcDSCmG1MXxSR1GAsXEV/Dwwykc2MPK8M2HN" crossorigin="anonymous">
    <!-- FontAwesome Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet" integrity="sha384-blOohCVdhjmtROpu8+CfTnUWham9nkX7P7OZQMst+RUnhtoY/9qemFAkIKOYxDI3" crossorigin="anonymous">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    
    <style>
        body {
            font-family: 'Roboto', sans-serif;
            background-color: #f4f6f9;
        }
        .sidebar {
            width: 275px;
            min-width: 275px;
            height: 100vh;
            position: sticky;
            top: 0;
            overflow-y: auto;
            z-index: 1020;
            display: flex;
            flex-direction: column;
            flex-shrink: 0;
            background-color: #1e293b;
            color: #f8fafc;
        }
        .sidebar::-webkit-scrollbar {
            width: 4px;
        }
        .sidebar::-webkit-scrollbar-thumb {
            background-color: #334155;
            border-radius: 4px;
        }
        .sidebar::-webkit-scrollbar-track {
            background-color: transparent;
        }
        .sidebar h5 {
            white-space: nowrap !important;
        }
        .sidebar .nav-link {
            white-space: nowrap !important;
            color: #94a3b8;
            padding: 10px 14px;
            font-size: 15px;
            display: flex;
            align-items: center;
            border-radius: 6px;
            margin: 3px 6px;
        }
        .sidebar .nav-link div,
        .sidebar .nav-link span {
            white-space: nowrap !important;
        }
        .sidebar .nav-link:hover, .sidebar .nav-link.active {
            color: #ffffff;
            background-color: #334155;
        }
        .sidebar .nav-link i {
            margin-right: 12px;
            width: 20px;
            text-align: center;
        }
        .main-content {
            padding: 25px;
        }
        .card-stat {
            border: none;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
            transition: transform 0.2s;
        }
        .card-stat:hover {
            transform: translateY(-3px);
        }
        .badge-condition {
            font-size: 12px;
            padding: 5px 10px;
            border-radius: 20px;
        }
    </style>
</head>
<body>
