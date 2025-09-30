-- ============================================
-- Laboratory Work #2: Advanced DDL Operations
-- File: lab2_advanced_ddl.sql
-- ============================================

-- ============================================
-- Part 1: Multiple Database Management
-- ============================================

-- Task 1.1: Database Creation with Parameters

-- 1. Create database university_main
CREATE DATABASE university_main
    WITH OWNER = postgres
    TEMPLATE = template0
    ENCODING = 'UTF8';

-- 2. Create database university_archive
CREATE DATABASE university_archive
    WITH CONNECTION LIMIT = 50
    TEMPLATE = template0;

-- 3. Create database university_test
CREATE DATABASE university_test
    WITH IS_TEMPLATE = TRUE
    CONNECTION LIMIT = 10;

-- ============================================
-- Task 1.2: Tablespace Operations
-- ============================================

-- 1. Create tablespace student_data
CREATE TABLESPACE student_data
    LOCATION '/data/students';

-- 2. Create tablespace course_data
CREATE TABLESPACE course_data
    OWNER postgres
    LOCATION '/data/courses';

-- 3. Create database university_distributed
CREATE DATABASE university_distributed
    WITH TABLESPACE = student_data
    ENCODING = 'LATIN9';

-- ============================================
-- Part 2: Complex Table Creation
-- Database: university_main
-- ============================================

\c university_main;  -- подключаемся к базе university_main

-- ============================================
-- Task 2.1: University Management System
-- ============================================

-- Table: students
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone CHAR(15),
    date_of_birth DATE,
    enrollment_date DATE,
    gpa NUMERIC(3,2),
    is_active BOOLEAN DEFAULT TRUE,
    graduation_year SMALLINT
);

-- Table: professors
CREATE TABLE professors (
    professor_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    office_number VARCHAR(20),
    hire_date DATE,
    salary NUMERIC(12,2),
    is_tenured BOOLEAN DEFAULT FALSE,
    years_experience INT
);

-- Table: courses
CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    course_code CHAR(8) UNIQUE NOT NULL,
    course_title VARCHAR(100) NOT NULL,
    description TEXT,
    credits SMALLINT,
    max_enrollment INT,
    course_fee NUMERIC(10,2),
    is_online BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
);

-- ============================================
-- Task 2.2: Time-based and Specialized Tables
-- ============================================

-- Table: class_schedule
CREATE TABLE class_schedule (
    schedule_id SERIAL PRIMARY KEY,
    course_id INT REFERENCES courses(course_id),
    professor_id INT REFERENCES professors(professor_id),
    classroom VARCHAR(20),
    class_date DATE,
    start_time TIME WITHOUT TIME ZONE,
    end_time TIME WITHOUT TIME ZONE,
    duration INTERVAL
);

-- Table: student_records
CREATE TABLE student_records (
    record_id SERIAL PRIMARY KEY,
    student_id INT REFERENCES students(student_id),
    course_id INT REFERENCES courses(course_id),
    semester VARCHAR(20),
    year INT,
    grade CHAR(2),
    attendance_percentage NUMERIC(4,1),
    submission_timestamp TIMESTAMPTZ DEFAULT NOW()
);
