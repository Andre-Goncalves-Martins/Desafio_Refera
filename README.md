# Desafio_Refera

- Como requisitado o código que contabiliza as quantidades é o <a href="count_per_month.sql">count_per_month.sql</a>. O resultado dessa query é a seguinte tabela:
<img width="400" alt="image" src="https://user-images.githubusercontent.com/88164286/229213490-a092f29c-8744-4994-8265-1d259c2997aa.png">

### Observações
- O banco utilizado para executar a atividade foi o MySQL;
- Para chegar a estes valores com as bases passadas no desafio foram utilizadas as seguintes querys:
```sql
-- Adicionar o campo datetime_approved_cancelled na tabela service_order
ALTER TABLE service_order ADD datetime_approved_cancelled DATETIME;

-- Adicionar o campo datetime_first_budget_approved na tabela service_order
ALTER TABLE service_order ADD datetime_first_budget_approved DATETIME;


-- Atualizar os campos datetime_execution_budget_approved e datetime_approved_cancelled na tabela service_order
UPDATE service_order
	LEFT JOIN (
	  SELECT service_order_id,
	         MIN(created_at) AS first_approved_date,
	         MAX(CASE WHEN log_event.title IN ('Orçamento aprovado', 'Orçamento aprovado pelo pagador') THEN created_at ELSE NULL END) AS approved_date,
	         MAX(CASE WHEN log_event.title = 'Aprovação cancelada' THEN created_at ELSE NULL END) AS cancelled_date
	  FROM log_event
	  WHERE log_event.title IN ('Orçamento aprovado', 'Orçamento aprovado pelo pagador', 'Aprovação cancelada')
	  GROUP BY service_order_id
	) AS log_info ON log_info.service_order_id = service_order.id
SET datetime_execution_budget_approved = CASE
		  WHEN cancelled_date IS NOT NULL THEN NULL
		  ELSE approved_date
		END,
	datetime_approved_cancelled = cancelled_date,
	datetime_first_budget_approved = first_approved_date
WHERE service_order.id IN (
  SELECT DISTINCT service_order_id
  FROM log_event
  WHERE log_event.title IN ('Orçamento aprovado', 'Orçamento aprovado pelo pagador', 'Aprovação cancelada')
);
