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
-- ROLLUP과 절대 뗄 수 없는 함수다. GROUPING 함수는 특정 컬럼의 값이 소계인지 아닌지 구분해준다.(GROUPING SETS과는 전혀 다른 기능이다.)
-- GROUPING 함수는 해당 컬럼이 ROLLUP 처리되었으면 1을 반환하고, 그렇지 않으면 0을 반환한다.
SELECT T1.ORD_ST, GROUPING(T1.ORD_ST) GR_ORD_ST
	 , T1.PAY_TP, GROUPING(T1.PAY_TP) GR_PAY_ST
	 , COUNT(*) ORD_CNT
FROM T_ORD T1
GROUP BY ROLLUP(T1.ORD_ST, T1.PAY_TP);


-- 1.2.4 ROLLUP 컬럼의 선택
-- 특정 컬럼의 소계만 필요하거나 전체 합계만 필요할 때가 있다. 이떄로 ROLLUP으로 해결할 수 있다.
-- ROLLUP의 위치를 옮기거나 소계가 필요한 대상을 괄호로 조정하면 된다. 특히 전체 합계만 추가하는 기능은 매우 유용하다.
SELECT CASE WHEN GROUPING(TO_CHAR(T2.ORD_DT, 'YYYYMM'))=1 THEN 'Total'
			ELSE TO_CHAR(T2.ORD_DT, 'YYYYMM') END ORD_YM
	 , CASE WHEN GROUPING(T1.RGN_ID)=1 THEN 'Total' ELSE T1.RGN_ID END RGN_ID
	 , CASE WHEN GROUPING(T1.CUS_GD)=1 THEN 'Total' ELSE T1.CUS_GD END CUS_GD
	 , SUM(T2.ORD_AMT) ORD_AMT
FROM M_CUS T1
   , T_ORD T2
WHERE T1.CUS_ID = T2.CUS_ID
AND   T2.ORD_DT >= TO_DATE('20170201', 'YYYYMM')
AND   T2.ORD_DT < TO_DATE('20170401', 'YYYYMM')
AND   T1.RGN_ID IN ('A', 'B')
GROUP BY ROLLUP(TO_CHAR(T2.ORD_DT, 'YYYYMM'), T1.RGN_ID, T1.CUS_GD)
ORDER BY TO_CHAR(T2.ORD_DT, 'YYYYMM'), T1.RGN_ID, T1.CUS_GD;

-- 여러 컬럼을 하나의 괄호로 묶으면 전체합계와 일부 컬럼만 소계를 내야 할 때 매우 유용하다. 
GROUP BY ROLLUP((TO_CHAR(T2.ORD_DT, 'YYYYMM'), T1.RGN_ID, T1.CUS_GD))

-- ROLLUP의 컬럼을 묶을 때 다음 두 가지만 정확히 기억하자.
-- 첫째, 여러 개의 컬럼이 GROUP BY될 때 전체합계만 필요하다면, GROUP BY ROLLUP((A, B, C, D))와 같이 사용한다. A, B, C, D가 하나의 단위로 ROLLUP되므로 전체합계만 결과에 추가된다.
-- 둘째, 여러 개의 컬럼 중 앞쪽 3개 컬럼까지의 소계와 전체합계 필요하면 솔계가 필요 없는 부분을 괄호로 묶으면 된다. GROUP BY ROLLUP(A, B, C, (D, E, F))와 같이 구현하면 된다.
-- 자주 사용하지 않으면 쉽게 이해하기 어려운 부분이기에 전체 합계를 구할 때 괄호 두 개를 사용하면 된다는 것만 정확히 기억해도 충분하다.


-- 1.3 소계를 구하는 다른 방법



-- 1.3.1 ROLLUP을 대신하는 방법
-- 소계를 구학기 위해 ROLLUP을 반드시 사용해야 하는 것은 아니다. ROLLUP을 대신할 수 있는 다양한 방법이 있다. 
-- ROLLUP을 경우에 따라 사용할 수 없는 상황도 있다.

-- (1) UNION ALL로 대신하기
-- UNION ALL을 사용하면 테이블을 ROLLUP의 수 만큼 접근해야 하기 때문에 성능에서 손해를 볼 수 밖에 없다. 소계가 필요한 만큼 UNION ALL이 늘어나 성능은 점점 나빠진다.
-- UNION ALL이 많아질수록 SELECT 절의 컬럼 순서를 맞추는 작업도 번거로워지는 단점이 있다.

-- (2) 카테시안-조인으로 대신하기
-- CARTESIAN-JOIN을 사용해 소계와 전체합계를 만들어 낼 수 있다. 
-- FROM 절에 두 개 이상의 테이블이 있을 떄, 조인-조건을 주지 않으면 CARTESIAN-JOIN이 발생한다. 조인 대상의 건수를 곱한 만큼 결과가 만들어진다.
-- 5건, 10건 존재 하는 각각의 테이블이 있을 때 50건의 조인 결과가 나온다.

