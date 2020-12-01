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


