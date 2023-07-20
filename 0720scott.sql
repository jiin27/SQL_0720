/* 1. 파라미터를 사용하지 않는 프로시저 */
CREATE OR REPLACE PROCEDURE PROC
AS
V_EMPNO NUMBER(4) := 1234;
BEGIN
DBMS_OUTPUT.PUT_LINE('V_EMPNO : ' || V_EMPNO);
END;
/

/* 1-1. 프로시저 PROC를 테스트하는 부분 */
SET SERVEROUTPUT ON ;
  exec proc;



/* 2. 프로시저 실행에 필요한 값을 직접 입력 받는 형식 */
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

/*2-1. 프로시저 PROC 를 테스트*/
BEGIN
    PROC_PARAMS(1,2);
END;



/* 3. 프로시저 실행 후 호출한 프로그램으로 값을 반환 받을 수 있는 방식 */
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

/* 3-1. 프로시저 PROC를 테스트 */
DECLARE
	param1 NUMBER;
BEGIN
	PROC_OUT(param1);
	DBMS_OUTPUT.PUT_LINE('param1: ' || param1);
END;



/* 트리거 TRIGGER */
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
/* 트리거 실행 */
insert into emp(empno, ename) values (88, '88길동'); /* 'Inserting...' 출력 트리거 실행됨 */
update emp set sal = sal + 10 where empno = 7369;  /* 'Updating sal...' 출력 트리거 실행됨 */
update emp set ename = '신윤복' where empno = 7369;  /* 'Updating ename...' 출력 트리거 실행됨 */

select * from emp;



/* 행트리거 예제 */
/*1. 백업 테이블 생성*/
create table emp_bak (
     old_sal number,
     new_sal number,
     u_date date,
     action varchar2(20));
     
/*트리거 생성*/
create or replace trigger tr_emp_update
      after update of sal on emp
      for each row
begin
      insert into emp_bak values (:old.sal, :new.sal, sysdate,'UPDATE');
end;
/

/*트리거 실행*/
select * from emp_bak;
update emp set sal = sal + 500;
select * from emp_bak;
DROP TRIGGER CHK_EMP;


/* 2. 트리거 예제 */
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
      dbms_output.put_line(',급여차이 ' || sal_diff); 
END; 
/ 
/* 2-1. 트리거 실행-삭제 */
update emp set sal=0;
rollback;
update emp set sal=501;
select * from emp;
DROP TRIGGER print_emp;



/* 레코드 RECORD */
/* 레코드 정의 */
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

/* 레코드_INSERT */
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

/* 레코드_UPDATE */
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

/* 레코드_레코드를 포함하는 레코드*/
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



/* 컬렉션(index 키와 value 값으로 구성) */
/* 연관배열 (배열의 크기가 고정돼 있어 활용도 多)*/
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

/* 가변길이 배열 (배열의 크기가 가변적인 건 데이터베이스에서 조심해야 한다_오류 가능성이 많음) */
DECLARE
    TYPE va_type IS VARRAY(5) OF VARCHAR2(20);
    vva_test va_type;
BEGIN
    vva_test := va_type('FIRST', 'SECOND', 'THIRD', '', '');
    FOR i IN 1..5 LOOP
       DBMS_OUTPUT.PUT_LINE(vva_test(i));
    END LOOP;
END;

/* +초기화 되지 않은 가변 배열 값에 접근할 때 */
DECLARE
    TYPE va_type IS VARRAY(5) OF VARCHAR2(20);
    vva_test va_type;
BEGIN
    vva_test := va_type('FIRST', 'SECOND', 'THIRD');  /* 하나의 테이블처럼 */
    FOR i IN 1..3
    LOOP
    DBMS_OUTPUT.PUT_LINE(vva_test(i));
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(vva_test(4)); /* 5개 크기의 배열을 선언했지만, 3개 값만 초기화 했다면 초기화 안된 배열 값에 접근은 오류 발생 */
END;



/* 컬렉션 메서드 */
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

