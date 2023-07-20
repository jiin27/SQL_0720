/* 1. �Ķ���͸� ������� �ʴ� ���ν��� */
CREATE OR REPLACE PROCEDURE PROC
AS
V_EMPNO NUMBER(4) := 1234;
BEGIN
DBMS_OUTPUT.PUT_LINE('V_EMPNO : ' || V_EMPNO);
END;
/

/* 1-1. ���ν��� PROC�� �׽�Ʈ�ϴ� �κ� */
SET SERVEROUTPUT ON ;
  exec proc;



/* 2. ���ν��� ���࿡ �ʿ��� ���� ���� �Է� �޴� ���� */
CREATE OR REPLACE PROCEDURE PROC_PARAMS
(
	param1 IN NUMBER,
	param2 NUMBER
)
AS
BEGIN
	DBMS_OUTPUT.PUT_LINE('param1: ' || param1);
	DBMS_OUTPUT.PUT_LINE('param2: ' || param2);
END;

/*2-1. ���ν��� PROC �� �׽�Ʈ*/
BEGIN
    PROC_PARAMS(1,2);
END;



/* 3. ���ν��� ���� �� ȣ���� ���α׷����� ���� ��ȯ ���� �� �ִ� ��� */
CREATE OR REPLACE PROCEDURE PROC_OUT
(
	param1 OUT NUMBER
)
AS
BEGIN
	SELECT DEPTNO INTO param1
	FROM DEPT
	WHERE DEPTNO = 10;
END PROC_OUT;

/* 3-1. ���ν��� PROC�� �׽�Ʈ */
DECLARE
	param1 NUMBER;
BEGIN
	PROC_OUT(param1);
	DBMS_OUTPUT.PUT_LINE('param1: ' || param1);
END;



/* Ʈ���� TRIGGER */
CREATE OR REPLACE TRIGGER CHK_EMP
      BEFORE INSERT OR  UPDATE OF ename, sal OR DELETE ON emp
 BEGIN
      CASE
        WHEN INSERTING THEN
           DBMS_OUTPUT.PUT_LINE('Inserting...');
        WHEN UPDATING('sal') THEN
           DBMS_OUTPUT.PUT_LINE('Updating sal...');
        WHEN UPDATING('ename') THEN
           DBMS_OUTPUT.PUT_LINE('Updating ename...');
       WHEN DELETING THEN
          DBMS_OUTPUT.PUT_LINE('Deleting...');
     END CASE;
END;
/
/* Ʈ���� ���� */
insert into emp(empno, ename) values (88, '88�浿'); /* 'Inserting...' ��� Ʈ���� ����� */
update emp set sal = sal + 10 where empno = 7369;  /* 'Updating sal...' ��� Ʈ���� ����� */
update emp set ename = '������' where empno = 7369;  /* 'Updating ename...' ��� Ʈ���� ����� */

select * from emp;



/* ��Ʈ���� ���� */
/*1. ��� ���̺� ����*/
create table emp_bak (
     old_sal number,
     new_sal number,
     u_date date,
     action varchar2(20));
     
/*Ʈ���� ����*/
create or replace trigger tr_emp_update
      after update of sal on emp
      for each row
begin
      insert into emp_bak values (:old.sal, :new.sal, sysdate,'UPDATE');
end;
/

/*Ʈ���� ����*/
select * from emp_bak;
update emp set sal = sal + 500;
select * from emp_bak;
DROP TRIGGER CHK_EMP;


/* 2. Ʈ���� ���� */
CREATE OR REPLACE TRIGGER print_emp 
      BEFORE UPDATE ON emp 
      FOR EACH ROW 
      WHEN (new.sal > 500) 
DECLARE 
      sal_diff number; 
BEGIN 
      sal_diff  := :new.sal  - :old.sal; 
      dbms_output.put('OLD SALARY : ' || :old.sal); 
      dbms_output.put(',NEW SALARY : ' || :new.sal); 
      dbms_output.put_line(',�޿����� ' || sal_diff); 
END; 
/ 
/* 2-1. Ʈ���� ����-���� */
update emp set sal=0;
rollback;
update emp set sal=501;
select * from emp;
DROP TRIGGER print_emp;



/* ���ڵ� RECORD */
/* ���ڵ� ���� */
DECLARE 
   TYPE REC_DEPT IS RECORD( 
      deptno NUMBER(2) NOT NULL := 99, 
      dname DEPT.DNAME%TYPE, 
      loc DEPT.LOC%TYPE 
   ); 
   dept_rec REC_DEPT;
BEGIN 
   dept_rec.deptno := 99; 
   dept_rec.dname := 'DATABASE'; 
   dept_rec.loc := 'SEOUL'; 
   DBMS_OUTPUT.PUT_LINE('DEPTNO : ' || dept_rec.deptno); 
   DBMS_OUTPUT.PUT_LINE('DNAME : ' || dept_rec.dname); 
   DBMS_OUTPUT.PUT_LINE('LOC : ' || dept_rec.loc);
END;
/

/* ���ڵ�_INSERT */
CREATE TABLE DEPT_RECORD
AS SELECT * FROM DEPT;

DECLARE 
   TYPE REC_DEPT IS RECORD( 
      deptno NUMBER(2) NOT NULL := 99, 
      dname DEPT.DNAME%TYPE, 
      loc DEPT.LOC%TYPE 
   ); 
   dept_rec REC_DEPT;
BEGIN 
   dept_rec.deptno := 99; 
   dept_rec.dname := 'DATABASE'; 
   dept_rec.loc := 'SEOUL';
INSERT INTO DEPT_RECORD VALUES dept_rec;
END;
/

/* ���ڵ�_UPDATE */
DECLARE 
   TYPE REC_DEPT IS RECORD( 
     deptno NUMBER(2) NOT NULL := 99, 
     dname DEPT.DNAME%TYPE, 
     loc DEPT.LOC%TYPE 
   ); 
   dept_rec REC_DEPT;
BEGIN 
   dept_rec.deptno := 50; 
   dept_rec.dname := 'DB'; 
   dept_rec.loc := 'SEOUL'; 
   
   UPDATE DEPT_RECORD SET ROW = dept_rec 
   WHERE DEPTNO = 99;
END;
/

/* ���ڵ�_���ڵ带 �����ϴ� ���ڵ�*/
DECLARE 
   TYPE REC_DEPT IS RECORD( 
      deptno DEPT.DEPTNO%TYPE, 
      dname DEPT.DNAME%TYPE, 
      loc DEPT.LOC%TYPE 
   ); 
   TYPE REC_EMP IS RECORD( 
      empno EMP.EMPNO%TYPE, 
      ename EMP.ENAME%TYPE, 
      dinfo REC_DEPT 
   ); 
   emp_rec REC_EMP;
   
BEGIN 
   SELECT E.EMPNO, E.ENAME, D.DEPTNO, D.DNAME, D.LOC 
   INTO emp_rec.empno, emp_rec.ename, emp_rec.dinfo.deptno,
      emp_rec.dinfo.dname, emp_rec.dinfo.loc 
   FROM EMP E, DEPT D 
   WHERE E.DEPTNO = D.DEPTNO AND E.EMPNO = 7369; 
   DBMS_OUTPUT.PUT_LINE('EMPNO : ' || emp_rec.empno); 
   DBMS_OUTPUT.PUT_LINE('ENAME : ' || emp_rec.ename); 
   DBMS_OUTPUT.PUT_LINE('DEPTNO : ' || emp_rec.dinfo.deptno); 
   DBMS_OUTPUT.PUT_LINE('DNAME : ' || emp_rec.dinfo.dname); 
   DBMS_OUTPUT.PUT_LINE('LOC : ' || emp_rec.dinfo.loc);
END;
/



/* �÷���(index Ű�� value ������ ����) */
/* �����迭 (�迭�� ũ�Ⱑ ������ �־� Ȱ�뵵 ��)*/
DECLARE 
   TYPE ITAB_EX IS TABLE OF VARCHAR2(20)
   INDEX BY PLS_INTEGER;    
   text_arr ITAB_EX;
BEGIN 
   text_arr(1) := '1st data'; 
   text_arr(2) := '2nd data'; 
   text_arr(3) := '3rd data'; 
   text_arr(4) := '4th data'; 
   DBMS_OUTPUT.PUT_LINE('text_arr(1) : ' || text_arr(1)); 
   DBMS_OUTPUT.PUT_LINE('text_arr(2) : ' || text_arr(2)); 
   DBMS_OUTPUT.PUT_LINE('text_arr(3) : ' || text_arr(3)); 
   DBMS_OUTPUT.PUT_LINE('text_arr(4) : ' || text_arr(4));
END;
/

/* �������� �迭 (�迭�� ũ�Ⱑ �������� �� �����ͺ��̽����� �����ؾ� �Ѵ�_���� ���ɼ��� ����) */
DECLARE
    TYPE va_type IS VARRAY(5) OF VARCHAR2(20);
    vva_test va_type;
BEGIN
    vva_test := va_type('FIRST', 'SECOND', 'THIRD', '', '');
    FOR i IN 1..5 LOOP
       DBMS_OUTPUT.PUT_LINE(vva_test(i));
    END LOOP;
END;

/* +�ʱ�ȭ ���� ���� ���� �迭 ���� ������ �� */
DECLARE
    TYPE va_type IS VARRAY(5) OF VARCHAR2(20);
    vva_test va_type;
BEGIN
    vva_test := va_type('FIRST', 'SECOND', 'THIRD');  /* �ϳ��� ���̺�ó�� */
    FOR i IN 1..3
    LOOP
    DBMS_OUTPUT.PUT_LINE(vva_test(i));
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(vva_test(4)); /* 5�� ũ���� �迭�� ����������, 3�� ���� �ʱ�ȭ �ߴٸ� �ʱ�ȭ �ȵ� �迭 ���� ������ ���� �߻� */
END;



/* �÷��� �޼��� */
DECLARE 
   TYPE ITAB_EX IS TABLE OF VARCHAR2(20)
   INDEX BY PLS_INTEGER;    
   text_arr ITAB_EX;
BEGIN 
   text_arr(1) := '1st data'; 
   text_arr(2) := '2nd data'; 
   text_arr(3) := '3rd data'; 
   text_arr(50) := '50th data'; 
   DBMS_OUTPUT.PUT_LINE('text_arr.COUNT : ' || text_arr.COUNT); 
   DBMS_OUTPUT.PUT_LINE('text_arr.FIRST : ' || text_arr.FIRST); 
   DBMS_OUTPUT.PUT_LINE('text_arr.LAST : ' || text_arr.LAST); 
   DBMS_OUTPUT.PUT_LINE('text_arr.PRIOR(50) : ' || text_arr.PRIOR(50)); 
   DBMS_OUTPUT.PUT_LINE('text_arr.NEXT(50) : ' || text_arr.NEXT(50));
END;
/

