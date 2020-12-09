-- 개발에 유용한 SQL 문법 세 가지를 정리한다. 
-- 서브쿼리, MERGE, WITH

-- 3.1 서브쿼리
-- 3.1.1 서브쿼리
-- 서브쿼리는 조인과 유사하면서도 조인보다 이해가 쉬윈 장점이 있다.

-- 서브쿼리를 익히기 전에, 서브쿼리는 성능이 좋지 못할 수 있다는 젓을 알기 바란다.
-- SQL의 실행계획이 특정된 방법으로 제약될 가능성이 있기 때문이ㅏㄷ. 그렇다고 서브쿼리가 무조건 성능이 나쁜 것은 아니다.
-- 때에 따라서 서브쿼리가 더 좋은 성능을 내는 예도 있다.

-- * 실행계획: SQL을 실행하면 오라클은 실행계획을 만든다. 실헹계획에 따라 SQL의 성능이 달라진다.

-- 서브쿼리를 익힌 후 가장 조심할 부분은 무분별한 서브쿼리 남발이다. 모든 조인을 서브쿼리로 해결하려 해서는 안된다. 
-- 성능에 영향을 주지 않는 범위에서 적헐하게 사용해야 한다.

-- 서브쿼리는 사용 위치와 방법에 따라 다음 네 가지로 분류할 수 있다.

-- - SELECT 절의 단독 서브쿼리
-- - SELECT 절의 상관 서브쿼리
-- - WHERE 절의 단독 서브쿼리
-- - WHERE 절의 상관 서브쿼리

-- 위 목목에는 없지만 인라인-뷰도 서브쿼리의 한 종류이다.
-- 메인 SQL과 상관없이 실행 할 수 있으면 단독 서브쿼리라 하고, 메인 SQL에 값을 받아서 처리해야 하면 상관 서브쿼리라고 한다.
-- 보통 SELECT 절에서 사요되는 서브쿼리는 스칼라 서브쿼리라고 부른다.

-- 3.1.2 SELECT 절의 단독 서브쿼리
-- SELECT 절의 서브쿼리는 어려운 SQL을 해결하기에 가장 손쉬운 방법이다.
-- SELECT 절의 단독 서브쿼리는 SQL의 SELECT 절에 사용이 되며 메인 SQL과 상관없이 단독으로 실행 가능한 서브쿼리를 뜻한다.
SELECT TO_CHAR(T1.ORD_DT, 'YYYYMM') ORD_YMD
	 , SUM(T1.ORD_AMT) ORD_AMT
	 , (
	 	SELECT SUM(A.ORD_AMT)
	 	FROM T_ORD A
	 	WHERE A.ORD_DT >= TO_DATE('20200801', 'YYYYMM')
	 	AND   A.ORD_DT < TO_DATE('20200901', 'YYYYMM')
	 	) TOTAL_ORD_AMT
FROM T_ORD T1
WHERE T1.ORD_DT >= TO_DATE('20190801', 'YYYYMM')
AND   T1.ORD_DT < TO_DATE('20190901', 'YYYYMM')
GROUP BY TO_CHAR(T1.ORD_DT, 'YYYYMM');

-- 3.1.3 SELECT 절의 상관 서브쿼리
-- SELECT 절의 상관 서브쿼리는 메인 SQL에서 조건 값을 받아 처리한다.
-- SELECT 절의 상관 서브쿼리는 코드성 데이터의 명칭을 가져오기 위해 사용할 수 있다. 또는 조인으로 가져오기 어려운 값을 처리하기 위해 사용할 수 있다.
-- SELECT 절의 상관 서브쿼리를 이용하면 대부분의 조인을 해결 할 수 있다. 하지만 모든 조인을 서브쿼리로 처리해서는 곤란하다.

-- 반복해서 서브쿼리 남발에 대한 주의사항을 언급하는 이유는 서브쿼리로 고통받는 SQL을 너무도 많이 봐왔기 떄문이다. 
SELECT T1.ITM_TP
	 , (SELECT A.BAS_CD_NM
	 	FROM   C_BAS_CD A
	 	WHERE  A.BAS_CD_DV = 'ITM_TP' AND A.BAS_CD = T1.ITM_TP AND A.LNG_CD = 'KO') ITM_TP_NM
	 , T1.ITM_ID, T1.ITM_TP_NM
FROM M_ITM T1;

-- 코드명 처리는 조인보다는 SELECT 절의 상관 서브쿼리를 사용하는 것이 일반적이다. 
-- 코드처럼 값의 종류가 많지 않은 경우는 서브쿼리를 사용하면 캐싱 효과로 성능이 더 좋아질 수도 있다.

-- 서브쿼리 캐싱 효과: 서브쿼리의 입력값과 결괏값을 캐시에 저장해 놓고 재사용하는 것을 뜻한다. 입력된 값이 캐시에 존재하면 서브쿼리의 실행없이 
-- 캐시의 값을 그대로 사용해 빠른 응답 속도를 제공한다. 서브쿼리를 위해 사용할 수 있는 캐시는 무제한이 아니다.
-- 코드와 같이 값의 종류가 작을 때만 캐싱 효과를 극대화 할 수 있다.

-- 3.1.4 SELECT 절 서브쿼리 - 단일 값
-- SELECT 절의 서브쿼리는 단일 값을 내보내야 한다. 여기서 단일 값이란, 하나의 로구 그리고 하나의 컬럼으로 구성된 단 하나의 값을 뜻한다.
-- 바꿔 말하면 SELECT 절의 서브쿼리가 두 건 이상의 결과를 내보내거나 두 개 컬럼 이상의 결과를 내보내면 안 된다.

-- 3.1.5 WHERE 절 단독 서브쿼리
-- 서브쿼리는 WHERE 절에서도 단독으로 사용할 수 있다.

-- 3.1.6 WHERE 절 상관 서브쿼리
-- WHERE 절의 상관 서브쿼리는 데이터의 존재 여부를 파악할 때 자주 사용한다. 예를 들어, 특정 일자나 특정 월에 주문이 존재하는 고객 리스트를 뽑을 때 아주 유용하다.
-- 3월에 주문이 존재하는 고객들을 조회하는 SQL
SELECT *
FROM M_CUS T1
WHERE EXISTS(
		SELECT * 
		FROM  T_ORD A
		WHERE A.CUS_ID = T1.CUS_ID
		AND   A.ORD_DT >= TO_DATE('20170301', 'YYYYMMDD')
		AND   A.ORD_DT <  TO_DATE('20170401', 'YYYYMMDD')
	 );

-- 위 SQL은 3우러에 주문이 한 건이라도 존재하는 고객을 조회한다. 반대로 3월에 주문이 한 건도 없는 고객을 조회해야 한다면 NOT EXISTS를 사용하면 된다.
-- 이 처럼 WHERE 절의 상관 서브쿼리는 다른 테이블에 데이터 존재 여부를 파악할 때 유용하다.

-- WHERE 절의 서브쿼리 안에서도 조인을 사용할 수 있다.


-- 3.2 MERGE
-- 데이터의 존재 여부에 따라 데이터를 INSERT 하거나 UPDATE 하는 경우가 많다. 이때 유용하게 사용할 수 있는 것이 MERGE다.
-- MERGE는 한 문장으로 INSERT와 UPDATE를 동시에 처리할 수 있다. 한 건의 데이터가 동시에 INSERT와 UPDATE 되는 것은 아니다. 한 건의 데이터는 INSERT와 UPDATE 중 하나만이
-- 수행된다. MERGE 대상이 이미 존재하면 UPDATE를, 대상이 존재하지 않으면 INSERT를 수행하는 방식이다.

-- 같은 고객 ID가 이미 있으면 고객 정보를 업데이트하고, 같은 고객ID가 없으면 신규 고객으로 등록을 한다.

-- 이와 같은 로직을 처리하기 위해 아래와 같이 PL/SQL을 사용해 보자. (PL/SQL은 오라클이 제공하는 절차형 언어 형식의 SQL 블록이라고 생각하면 된다.)
-- PL/SQL로 처리하기 위해서는 SQL 문장들을 BEGIN과 END 블록으로 감싸서 처리하면 된다.
DECLARE v_EXISTS_YN varchar(1);
BEGIN
	SELECT NVL(MAX('Y'), 'N')
	INTO v_EXISTS_YN
	FROM DUAL A
	WHERE EXISTS(
			SELECT *
			FROM M_CUS_CUD_TEST T1
			WHERE T1.CUS_ID = 'CUS_0000'
		);

	IF v_EXISTS_YN = 'N' THEN
		INSERT INTO M_CUS_CUD_TEST (CUS_ID, CUS_NM, CUS_GD)
		VALUES ('CUS_0090', 'NAME_0090', 'A');
	ELSE
		UPDATE M_CUS_CUD_TEST T1
		SET    T1.CUS_NM = 'NAME_0090'
			 , T1.CUS_GD = 'A'
		WHERE  CUS_ID = 'CUS_0090'
		;

		DBMS_OUTPUT.PUT_LINE('UPDATE OLD CUST');
	END IF;
	COMMIT;
END;

-- EXISTS, INSERT, UPDATE 이 3개의 SQL은 하나의 MERGE 문장으로 처리할 수 있다.
MERGE INTO M_CUS_CUD_TEST T1
USING (
	  SELECT 'CUS_0090' CUS_ID
	       , 'NAME_0090' CUS_NM
	       , 'A' CUS_GD
	  FROM DUAL
	  ) T2
	  ON (T1.CUS_ID = T2.CUS_ID)
WHEN MATCHED THEN UPDATE SET T1.CUS_NM = T2.CUS_NM
						   , T1.CUS_GD = T2.CUS_GD
WHEN NOT MATCHED THEN INSERT (T1.CUS_ID, T1.CUS_NM, T1.CUS_GD)
					  VALUES (T2.CUS_iD, T2.CUS_NM, T2.CUS_GD)
COMMIT;

-- MERGE 문에는 'MERGE 대상'과 '비교 대상'이 있다. 각각을 설명하면 아래와 같다.
-- MERGE 대상: UPDATE되거나, INSERT 될 테이블
-- : MERGE INTO 절 뒤에 정의한다.
-- : 위 SQL에서는 M_CUS_CUD_TEST가 MERGE 대상이다. T1이 별칭이다.
-- 비교 대상: MERGE 대상의 처리 방법을 결정할 비교 데이터 집합
-- : USING 절 뒤에 정의한다.
-- : 위 SQL에서는 2~7번 라인의 인라인-뷰가 비교 대상이다. T2가 별칭이다.
-- : 여러 건을 비교 대상으로 정의할 수 있다.

-- MERGE 대상과 비교 대상은 ON 절을 이용해 '비교 조건'을 정의한다. 위 SQL에서 8번 라인에 해당한다.
-- 비교 조건의 결과에 따라 UPDATE나 INSERT를 처리할 수 있다. '비교 조건' 결과에 따라 아래와 같이 처리한다.
-- WHEN MATCHED THEN: 비교 대상의 데이터가 MERGE 대상에 이미 있음
-- : MERGE 대상을 UPDATE 처리하면 된다.
-- WHEN NOT MATCHED THEN: 비교 대상의 데이터가 MERGE 대상에 없음
-- : MERGE 대상에 새로운 데이터를 입력하면 된다.


-- 3.2.2 MERGE를 사용한 UPDATE
