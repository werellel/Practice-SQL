-- 1.1 GROUP BY



-- 1.1.1 GROUP BY 이해하기

-- 데이터 그룹화 문법 SUM, MIN, MAX, COUNT와 같은 집계 함수와 사용할 수 있다.
-- 이 외에도 평균이나 표준편차와 같은 다양한 집계함수가 있다. 
-- 집계함수는 SELECT 절에서 GROUP BY 없이도 사용가능하다.

-- 다음의 규칙을 기억하자.
-- - GROUP BY에 사용한 컬럼만 SELECT 절에서 그대로 사용할 수 있다. 
-- - GROUP BY에 사용하지 않은 컬럼은 SELECT 절에서 집계함수를 사용해야 한다.


-- 1.1.2 GROUP BY 컬럼의 변형

-- 변형을 위해 TO_CHAR, TO_DATE와 같은 기본 함수뿐 아니라 CASE(또는 DECODE)와 같은 치환 문법도 사용할 수 있다.

-- CASE를 이용한 가격유형별 주문 건수를 카운트
SELECT T1.ORD_ST
		,CASE WHEN T1.ORD_AMT >= 5000 THEN 'High Order'
			  WHEN T1.ORD_AMT >= 3000 THEN 'Middle Order'
			  ELSE 'Low Order'
		END ORD_AMT_TP
		,COUNT(*) ORT_CNT
FROM T_ORD T1
GROUP BY T1.ORD_ST
		 ,CASE WHEN T1.ORD_AMT >= 5000 THEN 'High Order'
		 	   WHEN T1.ORD_AMT >= 3000 THEN 'Middle Order'
		 	   ELSE 'Low Order'
		 END
ORDER BY 1, 2;

-- CASE를 활용한 데이터 치환은 추가적인 테이블 변경이나 프로그램 작업 없이 SQL만으로 많은 문제를 해결할 수 있게 해준다.
-- CASE는 ORDER BY에도 사용할 수 있다.

-- 위와 같이 주문금액을 CASE로 분류하는 것은 좋은 방법이 아니다. 일회성으로 사용하는 SQL이라면 위와 같인 작성해도 상관없다.
-- 하지만 실제 운영 화면에서는 SQL을 사용하면 안된다. 혹시라도 ORD_AMT의 기준이 변경되면 SQL을 변경해야 하기 때문이다. 


-- 1.1.2 집계함수에서 CASE문 활용하기

-- 주문년월별 계좌이체 건수와 카드결제 건수
SELECT TO_CHAR(T1.ORD_DT, 'YYYYMM') ORD_YM
	   ,SUM(CASE WHEN T1.PAY_TP = 'BANK' THEN 1 END) BANK_PAY_CNT
	   ,SUM(CASE WHEN T1.PAY_TP = 'CARD' THEN 1 END) CARD_PAY_CNT
FROM T_ORD T1
WHERE T1.ORF_ST = 'COMP'
GROUP BY TO_CHAR(T1.ORD_DT, 'YYYYMM')
ORDER BY TO_CHAR(T1.ORD_DT, 'YYYYMM');


-- 1.1.3 COUNT 집계함수

-- COUNT는 좀 더 자세히 들여다볼 필요가 있다. 사용방법에 따라 다른 결과가 나올 수 있기 때문이다.
-- NULL에 대한 COUNT
-- COUNT 집계함수는 NULL값을 0으로 카운트한다. COUNT(COR1)은 컬럼의 값에 대한 카운트라면 
-- COUNT(*)는 로우 자체의 건수를 카운트한다. 

-- 위와 같은 특징을 정확히 기억하고 COUNT를 사용해야 한다. 특히 아우터-조인의 경우 COUNT(*)와 COUNT(컬럼명)을 상황에 따라 적절히 사용해야 한다.


--  1.1.4 중복을 제거한 COUNT
-- COUNT안에서 DISTINCT를 사용하면 중복이 제거된다. 
-- COUNT(DISTINCT)는 여러 컬럼을 동시에 사용할 수 없다. 

-- 1.1.5 HAVING
-- HAVING 절은 GROUP BY가 수행된 결과 집합에 조건을 줄 때 사용한다. WHERE 절과 같은 기능이라고 생각하면 된다.
-- HAVNING은 GROUP BY 뒤에 위치한다. WHERE절 처럼 여러개의 AND나 OR를 이용해 조건을 줄 수 있다.


-- 1.2 ROLLUP



-- 1.2.1 ROLLUP 이해하기
-- 대부분의 분석 리포트는 소계(중간합계)와 전체합계가 필요하다. 소계와 전체합계를 구하는 방법에는 여러 가지가 있지만, BI툴 없이 순수 SQL만 사용해야 한다면 
-- ROLLUP이 가장 효율적이다. ROLLUP을 자유자재로 사용할 수 있다면 어떤 소계든지 SQL만으로 해결할 수 있다.

-- ROLLUP은 GROUP BY뒤에 ROLLUP이라고 적어서 사용한다. 예를 들어, GROUP BY ROLLUP(A, B, C, D)라고 사용하면 다음과 같은 데이터들이 조회된다.
-- GROUP BY된 A+B+C+D별 데이터
-- A+B+C별 소계 데이터
-- A+B별 소계 데이터
-- A별 소계 데이터
-- 전체합계

-- GROUP BY만 사용된 예
SELECT TO_CHAR(T1,ORD_DT, 'YYYYMM') ORD_YM
	   ,T1.CUS_ID
	   ,SUM(T1.ORD_AMT) ORD_AMT
FROM T_ORD T1
WHERE T1.CUS_ID IN ('CUS_0001', 'CUS_0002')
AND T1.ORD_DT >= TO_DATE('20201202', 'YYYYMM')
AND T1.ORD_DT < TO_DATE('20201202', 'YYYYMM')
GROUP BY TO_CHAR(T1.ORD_DT, 'YYYYMM'), T1.CUS_ID;

-- GROUP BY ROLLUP 예
SELECT TO_CHAR(T1,ORD_DT, 'YYYYMM') ORD_YM
	   ,T1.CUS_ID
	   ,SUM(T1.ORD_AMT) ORD_AMT
FROM T_ORD T1
WHERE T1.CUS_ID IN ('CUS_0001', 'CUS_0002')
AND T1.ORD_DT >= TO_DATE('20201202', 'YYYYMM')
AND T1.ORD_DT < TO_DATE('20201202', 'YYYYMM')
GROUP BY 
ROLLUP(TO_CHAR(T1.ORD_DT, 'YYYYMM'), T1.CUS_ID);

-- ROLLUP을 사용하면 소계와 전체합계를 추가할 수 있따.


-- 1.2.2 ROLLUP의 컬럼 순서
-- ROLLUP에 사용하는 컬럼 순서는 매우 중요하다. 컬럼 순서에 따라 다른 소계가 나오기 때문이다.
-- ROLLUP은 사영된 컬럼 순서대로 계층적 소계를 만든다. 아래 두 케이스를 살펴보자.
-- 1. GROUP BY ROLLUP(A, B, C, D): A + B + C별 소계, A + B별 소계, A별 소계, 전체 합계
-- 2. GROUP BY ROLLUP(B, A, C, D): B + A + C별 소계, B + A별 소계, B별 소계, 전체 합계

-- 1.2.3 GROUPING