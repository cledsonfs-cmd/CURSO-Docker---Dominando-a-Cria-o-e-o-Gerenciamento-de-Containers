-- =============================================================================
--
-- INICIO: I N T E G R A Ç Ã O   D O C U M E N T O S   D I G I T A I S 
--
-- =============================================================================
-- --------------------------------------------------------------------------------
-- Inserir Novo Tipo de Origem para Documentos Digitais gerados pelo Módulo de CONSERVA
-- --------------------------------------------------------------------------------
INSERT INTO documento_digital.tipo_origem_arquivo (id, cor, sigla, descricao, especificacao)
VALUES (7, '#000000', 'SSC', 'SIGSOP-Conserva','Documentos Gerados pelo Sistemas de Controle de Conservação de Rodovias');


-- --------------------------------------------------------------------------------
-- Relação de Tipos de Entidades para Gestão de Documentos digitais de conserva 
-- --------------------------------------------------------------------------------
-- Exclui referencia anterior dos codigos de Supervisão
DELETE FROM documento_digital.ponto_controle_x_tipo_doc 
      WHERE id_ponto_controle IN (SELECT qry.id as id_ponto_controle
                                    FROM documento_digital.ponto_controle qry 
                                   WHERE qry.id_tipo_entidade = 122);
                                   
DELETE FROM documento_digital.tipo_documento_x_tipo_assinador 
      WHERE id_tipo_documento IN (SELECT qry.id as id_tipo_documento
                                    FROM documento_digital.tipo_documento qry 
                                   WHERE qry.id_tipo_entidade = 122);
                                       
DELETE FROM documento_digital.ponto_controle WHERE id_tipo_entidade = 122;
DELETE FROM documento_digital.tipo_documento WHERE id_tipo_entidade = 122;
DELETE FROM documento_digital.tipo_assinador WHERE id in (113,114);
DELETE FROM documento_digital.tipo_entidade  WHERE id >=120 AND id <=133;

-- Inclui no lgar de supervisão os códigos de conserva
INSERT INTO documento_digital.tipo_entidade (id, id_tipo_entidade_pai, pasta, descricao, observacao) VALUES
--(120 ,100 ,'CTRCON' ,'Contrato de Conservação Rodoviaria'    ,'Documentos Relativos a operacionalização das Conservação de Rodovia'),
--(121 ,120 ,'CONPLA' ,'Planilha de Conservação das Rodovias'  ,'Documentos Relativos as planilhas de Conserva Rodoviaria'),
(122 ,100 ,'CONMED' ,'Medição da Conserva Rodoviaris'        ,'Documentos Relativos ao processo administrativo das medições de Conserva Rodoviaria'),
(123 ,122 ,'CONFIN' ,'Financeiro Medicao Conserva Rodoviaria','Documentos Relativos ao processo financeiro das medições de Conserva Rodoviaria');

-- Cadastra novamente as referencias a supervisão com novos códigos
INSERT INTO documento_digital.tipo_entidade (id, id_tipo_entidade_pai, pasta, descricao, observacao) VALUES
(130 ,100 ,'CTRSUP' ,'Supervisao de Obra'                    ,'Documentos Relativos a operacionalização das supervisões de obras de Rodovia'),
(131 ,130 ,'SUPPLA' ,'Planilha de Supervisão de Obras'       ,'Documentos Relativos as planilhas de supervisão de obras de Rodovia'),
(132 ,130 ,'SUPMED' ,'Medição da Supervisão de Obras'        ,'Documentos Relativos ao processo administrativo das medições de supervisão de obras de Rodovia'),
(133 ,130 ,'SUPFIN' ,'Financeiro das Supervisões de Obras'   ,'Documentos Relativos ao processo Financeiro das medições de supervisão de obras de Rodovia');

-- --------------------------------------------------------------------------------
-- Reçlação de Tipos de Assinadores referente a Gestão de Documentos digitais de conserva
-- --------------------------------------------------------------------------------
INSERT INTO documento_digital.tipo_assinador(id,tipo,id_assinador,cpf_assinador,descricao,label_etiqueta,especificacao) VALUES 
(113, 2, NULL, NULL, 'FISCAL_CONSERVA_RODOVIARIA', 'COMISSÃO', 'Comissao responsável pela medição de obra de edificações'),
(114, 2, NULL, NULL, 'COMISSAO_CONSERVA_RODOVIAS', 'COMISSÃO', 'Comissao responsável pela medição de manutenção de edificações');

-- --------------------------------------------------------------------------------
-- Relação de Pontos de Controle referente a Gestão de Documentos digitais de conserva
-- --------------------------------------------------------------------------------
INSERT INTO documento_digital.ponto_controle (id_tipo_entidade, id, requer_liberacao, id_tipo_ocorrencia_pce, id_validacao_adicional, sigla, descricao, especificacao) VALUES 
(122, 12221, FALSE, 1, 0, 'MCOAAZ', 'Med. Conserva Rod. (Antes de Apresentar Medição ZERO)',      'Validar Documentos Digitais Relativos a Medições de Conserva Rodoviaria (Antes de Apresentar Medição ZERO)'),
(122, 12225, TRUE , 1, 0, 'MCOAPZ', 'Med. Conserva Rod. (Antes de Protocolar Medição ZERO)',      'Validar Documentos Digitais Relativos a Medições de Conserva Rodoviaria (Antes de Protocolar Medição ZERO)'),
(122, 12231, TRUE , 1, 0, 'MCOAPV', 'Med. Conserva Rod. (Antes de Apresentar Medição com Valor)', 'Validar Documentos Digitais Relativos a Medições de Conserva Rodoviaria (Antes de Apresentar Medição com Valor)'),
(122, 12235, TRUE , 1, 0, 'MCOAPR', 'Med. Conserva Rod. (Antes de Protocolar Medição)',           'Validar Documentos Digitais Relativos a Medições de Conserva Rodoviaria (Antes de Protocolar Medição)'),
(123, 12345, TRUE , 2, 2, 'MCOAFE', 'Med. Conserva Rod. (Antes de Finalizar Empenho(s))',         'Validar Documentos Digitais Relativos ao Aspecto Financeiro da Medições de Conserva Rodoviaria (Antes de Finalizar Empenho(s))'),
(123, 12347, TRUE , 1, 3, 'MCOAFP', 'Med. Conserva Rod. (Antes de Finalizar Pagamento(s))',       'Validar Documentos Digitais Relativos ao Aspecto Financeiro da Medições de Conserva Rodoviaria (Antes de Finalizar Pagamento(s))');

-- --------------------------------------------------------------------------------
-- Relação de Tipos de Documentos Referente a Medição de Conserva
-- --------------------------------------------------------------------------------
INSERT INTO documento_digital.tipo_documento (id_tipo_entidade, id, id_tipo_versao, id_tipo_origem, requer_assinatura, unico_por_entidade, descricao, nome_arquivo, especificacao) VALUES 
(122, 12201, 0, 7, 'False','True', 'Capa de Medição',                'CapaMedicaoConserva',          'Relatório com informações sumarizadas da medição que serve como capa do processo da medição'),
(122, 12202, 0, 7, 'True', 'True', 'Justificatica de Medição ZERO',  'JustificativaMedicaoZero',     'Relatório que exibe uma justificativa informada pela empresa sobre o motivo da medição ser ZERO.'),
(122, 12203, 0, 7, 'False','True', 'Ficha do Contrato',              'FichaContratoConserva',        'Relatório com informações da Ficha doc ontrato de Conservação'),
(122, 12204, 0, 7, 'True', 'True', 'Certificado Entrega Medição',    'CertificadoEntregaMedicao',    'Relatório que atesta a entrega da medição.'),
(122, 12205, 0, 7, 'True', 'True', 'Ficha da Medição',               'FichaMedicaoConserva',         'Relatório com informações da Ficha doc ontrato de Conservação.'),
(122, 12206, 0, 3, 'True', 'True', 'Relatorio Fotográfico',          'RelatorioFotografico',         'Documento externo incluido via UPLOAD'),
(122, 12207, 0, 3, 'True', 'True', 'Relatorio Segurança do Trabalho','RelatorioSegurancaTrabalho',   'Documento externo incluido via UPLOAD'),
(122, 12208, 0, 3, 'True', 'True', 'Diario de Obra',                 'DiarioObra',                   'Documento externo incluido via UPLOAD'),
(122, 12209, 0, 3, 'True', 'True', 'Boletim de Medição',             'BoletimMedicaoConserva',       'Documento externo incluido via UPLOAD'),
(122, 12210, 0, 3, 'True', 'True', 'Memoria de Cálculo',             'MemoriaCalculoMedicaoConserva','Documento externo incluido via UPLOAD'),
(122, 12211, 0, 3, 'True', 'True', 'Carta de Entrega da Medição',    'CartaEntregaMedição',          'Documento externo incluido via UPLOAD');	

-- --------------------------------------------------------------------------------
-- Relação de Assinadores X tipo documento
-- --------------------------------------------------------------------------------
INSERT INTO documento_digital.tipo_documento_x_tipo_assinador (id_tipo_documento, id_tipo_assinador) VALUES 		
(12202,5), (12202,114),
(12204,5), 
(12205,5), (12205,114),
(12206,5), 
(12207,5), (12207,114),
(12208,5), (12208,114),
(12209,5), (12209,114),
(12210,5), (12210,114),
(12211,5);

-- --------------------------------------------------------------------------------
-- Relação de Ponto Controle X Tipo Documento
-- --------------------------------------------------------------------------------
INSERT INTO documento_digital.ponto_controle_x_tipo_doc (id_ponto_controle,id_tipo_documento,id_requer_envio,id_requer_conferencia,id_requer_assinatura,id_requer_carimbo) VALUES 
(12225,12201,12,21,30,40),(12235,12201,12,21,30,40),
(12225,12202,12,21,31,40),
(12225,12203,12,21,30,40),(12235,12203,12,21,30,40),
(12235,12204,12,21,31,40),
(12235,12205,12,21,30,40),
(12231,12206,12,20,30,40),(12235,12206,12,22,31,40),
(12231,12207,12,20,30,40),(12235,12207,12,22,31,40),
(12231,12208,12,20,30,40),(12235,12208,12,22,31,40),
(12231,12209,12,20,30,40),(12235,12209,12,22,31,40),
(12231,12210,12,20,30,40),(12235,12210,12,22,31,40),
(12231,12211,12,20,30,40),(12235,12211,12,22,31,40);

/*
Categoria de Tipos de Assinadores
1. Statico (Id_assinador e CPF na tsblea tipo ASSINADOR
2. Dinamico 1 (Id assinador e CPF na view (contexto referente a cada tipo
3. Dinamico 2 (id assinador Parametro adicional (id_pessoa_juridica) CPF quando assina
 */
-- ------------------------------------------------
-- Ajuta tipo 
UPDATE documento_digital.tipo_assinador 
   SET tipo = 3         -- 3-Novo Tipo assinador Criador para Dinamico
 WHERE id in (4, 5, 6); -- 4-CONTRATANTE 5-CONTRATADA 6-SUPERVISORA

 
-- ================================================================================
-- C O N T R O L E   d e   D E S P A C H O
-- --------------------------------------------------------------------------------
-- Insere tipo de origem do despacho virtual para contrato de conserva
-- --------------------------------------------------------------------------------
INSERT INTO controle_despachos.tipo_origem_despacho (id, sigla, nome_tabela, descricao, especificacao) VALUES
(122,'MCROD','controle_conservacao.medicoes', 'Medição de Conserva de Rodovia',	'Despacho com origem no protocolo de Medição de Conserva de Rodovia');

-- --------------------------------------------------------------------------------
-- Relação de Assunto para Tramitação do Despacho Virtual de Conserva
-- --------------------------------------------------------------------------------
INSERT INTO controle_despachos.assunto_tramitacao  (id, id_origem, id_setor_origem, descricao, especificacao) VALUES 
(15,122, 332,'Encaminhar Medição','Deve ser informado nas tramitações ref. a medição de obras de rodovias ao sair da GEMED'), 
(16,122,2706,'Encaminhar Medição','Deve ser informado nas tramitações ref. a medição de obras de rodovias ao sair da GEMED'),
(17,122,NULL,'Solicitação de Pagamento de Medição','A definir'),
(18,122,2704,'Autorização de Pagamento de Medição','A definir');

-- --------------------------------------------------------------------------------
-- Relação de Modelo de Tramitação do Despacho Virtual de Conserva
-- --------------------------------------------------------------------------------
INSERT INTO controle_despachos.modelo_tramitacao (id, id_assunto, id_setor_origem, id_dados_modelo, descricao, texto) VALUES 
(12201,16,2706,0,'Encaminhar Medição ZERO'   ,'Informamos que a medição ZERO, foi apresentada pela empresa no sistema SIGSOP-Conserva.'),
(12202,16,2706,0,'Encaminhar Medição PARCIAL','Sr. Diretor, Informamos que a documentação referente a Medição PARCIAL, está em conformidade com os serviços atestados pelo fiscal.'),
(12203,16,2706,0,'Encaminhar Medição FINAL'  ,'Sr. Superintendente, Informamos que a documentação referente a Medição FINAL, está em conformidade com os serviços atestados pelo fiscal.');


-- =============================================================================
--
-- FIM: I N T E G R A Ç Ã O   D O C U M E N T O S   D I G I T A I S 
--
-- =============================================================================

--------------------------------------------------------------------------------
-- VIEW....: documento_digital.vw_lista_id_tipo_entidade_despesa 
-- Objetivo: Utilizado como subquery na view: vw_lista_id_tipo_entidade
--------------------------------------------------------------------------------  
CREATE OR REPLACE VIEW documento_digital.vw_lista_id_tipo_entidade_despesa AS
SELECT CASE WHEN tab.id_tipo_origem = 0 THEN 999 -- 999-A definir
            WHEN tab.id_tipo_origem = 1 THEN 113 -- 113-Financeiro de Obra de Rodovias
            WHEN tab.id_tipo_origem = 2 THEN 123 -- 123-Financeiro de Conserva de Rodovias
            WHEN tab.id_tipo_origem = 3 THEN 999 -- 999-A definir
            WHEN tab.id_tipo_origem = 4 THEN 999 -- 999-A definir
            WHEN tab.id_tipo_origem = 5 THEN 999 -- 999-A definir
            WHEN tab.id_tipo_origem = 6 THEN 999 -- 999-A definir
            WHEN tab.id_tipo_origem = 7 THEN 213 -- 213-Financeiro Medições de Obras de Edificações
            WHEN tab.id_tipo_origem = 8 THEN 999 -- 999-A definir
       END              AS id_tipo_entidade,
       tab.id AS id_entidade, 
       CASE WHEN tab.id_tipo_origem = 0        THEN pr1.id_medicao -- 1-Obra de Rodovias
            WHEN tab.id_tipo_origem = 1        THEN pr1.id_medicao -- 1-Obra de Rodovias
            WHEN tab.id_tipo_origem = 2        THEN pr2.id         -- 2-Conserva Rodovias
            WHEN tab.id_tipo_origem IN (2,4,5) THEN prx.id_medicao -- (2-Conserva 4-Projeto 5-Administrativo)
            WHEN tab.id_tipo_origem = 3        THEN pr3.id_medicao -- 3-Supervisão de Obras
            WHEN tab.id_tipo_origem = 7        THEN pr7.id_medicao -- 7-Obras de Edificações
            WHEN tab.id_tipo_origem = 8        THEN pr8.id_medicao -- 8-Manutenção Predial
       END              AS id_entidade_pai,
       tab.nr_protocolo AS codigo_entidade,                
       FALSE            AS pasta_com_codigo
FROM      der_ce_financeiro_despesa.despesas                 tab
LEFT JOIN der_ce_medicao.processos_medicoes_obras            pr1 ON tab.id = pr1.id_despesa AND tab.id_tipo_origem = 1
LEFT JOIN controle_conservacao.medicoes                      pr2 ON tab.id = pr2.id_despesa AND tab.id_tipo_origem = 2
LEFT JOIN der_ce_medicao.processos_medicoes_obras            prx ON tab.id = prx.id_despesa AND tab.id_tipo_origem IN (2,4,5)
LEFT JOIN der_ce_supervisao_new.processo_medicao_supervisao  pr3 ON tab.id = pr3.id_despesa AND tab.id_tipo_origem = 3
LEFT JOIN der_ce_contrato_despesas.despesas_contrato         pr6 ON tab.id = pr6.id_despesa AND tab.id_tipo_origem = 6
LEFT JOIN dae_ce_medicao.processos_medicoes_obras            pr7 ON tab.id = pr7.id_despesa AND tab.id_tipo_origem = 7
LEFT JOIN dae_ce_medicao.processos_medicoes_obras            pr8 ON tab.id = pr8.id_despesa AND tab.id_tipo_origem = 8;


--------------------------------------------------------------------------------
-- VIEW....: documento_digital.vw_lista_id_tipo_entidade 
-- CLASSE..: der.ce.documento_digital.VoListIdTipoEntidade.java
-- Objetivo: Utilizado para Montar o caminho onde do repositório onde os arquivos serão armazenados
--------------------------------------------------------------------------------  
CREATE OR REPLACE VIEW documento_digital.vw_lista_id_tipo_entidade AS
	SELECT row_number() OVER () AS id, 
	       qry.id_tipo_entidade,
	       qry.id_entidade,
	       qry.id_entidade_pai,
	       qry.codigo_entidade,
	       qry.pasta_com_codigo
	FROM (-- =======================================================================
	      -- >>>      ENTIDADES RELACIONADA A CONTRATOS DO SIGSOP-RODOVIAS       <<<
	      -- =======================================================================
	      -- Entidade: 100 - CTRDER - Contrato de Despesa Rodovias
	      SELECT 100                 AS id_tipo_entidade,
	             tab.id              AS id_entidade,
	             NULL                AS id_entidade_pai,
	             tab.nr_contrato_der AS codigo_entidade,
	             TRUE                AS pasta_com_codigo
	      FROM   der_ce_contrato.contratos tab
	      -- -----------------------------------------------------------------------
	      -- Entidade: 101 - CTRALT - Alteração Contratual
	      UNION ALL
	      SELECT 101                 AS id_tipo_entidade,
	             tab.id              AS id_entidade,
	             tab.id_contrato     AS id_entidade_pai,
	             tab.nr_protocolo    AS codigo_entidade,
	             FALSE               AS pasta_com_codigo
	      FROM   der_ce_contrato_alteracoes.alteracoes_contratuais tab
	      -- -----------------------------------------------------------------------
	      -- Entidade: 102 - CTRDES - Despesa com Contrato (Para Qualquer tipo contrato)
	      UNION ALL
	      SELECT 102                 AS id_tipo_entidade,
	             tab.id              AS id_entidade,
	             tab.id_contrato     AS id_entidade_pai,
	             tab.nr_protocolo    AS codigo_entidade,
	             FALSE               AS pasta_com_codigo
	      FROM   der_ce_contrato_despesas.despesas_contrato tab
	      -- -----------------------------------------------------------------------
	      -- Entidade: 103 - CTRMED - Medição Contratos (Para contratos Tipo: (2-Conserva 4-Projeto 5-Administrativo)
	      UNION ALL 
	      SELECT 103                           AS id_tipo_entidade,
	             tab.id                        AS id_entidade,
	             tab.id_contrato               AS id_entidade_pai,
	             to_char(tab.nr_medicao,'000') AS codigo_entidade,
	             TRUE                          AS pasta_com_codigo
	      FROM   der_ce_contrato_medicoes.medicoes_contratos tab	            
	      -- =======================================================================
	      -- >>>           ENTIDADES RELACIONADA A OBRAS RODOVIARIA              <<<
	      -- =======================================================================
	      -- Entidade: 110 - CTROBR - Contrato de Obra
	      UNION ALL 
	      SELECT 110             AS id_tipo_entidade,
	             tab.id          AS id_entidade,
	             tab.id_contrato AS id_entidade_pai,
	             tab.codigo_obra AS codigo_entidade,
	             TRUE            AS pasta_com_codigo
	      FROM   der_ce_obra.obras tab
	      -- -----------------------------------------------------------------------
	      -- Entidade: 111 - OBRORC - Orçamento da Obra
	      UNION ALL 
	      SELECT 111             AS id_tipo_entidade,
	             tab.id          AS id_entidade,
	             tab.id_obra     AS id_entidade_pai,
	             obr.codigo_obra AS codigo_entidade,
	             FALSE           AS pasta_com_codigo
	      FROM   der_ce_orcamento.orcamentos tab
	      JOIN   der_ce_obra.obras           obr ON obr.id = tab.id_obra            
	      -- -----------------------------------------------------------------------
	      -- Entidade: 112 - OBRMED - Medição da Obra
	      UNION ALL 
	      SELECT 112                            AS id_tipo_entidade,
	             tab.id                         AS id_entidade,
	             tab.id_obra                    AS id_entidade_pai,  
	             to_char(tab.nr_medicao,'000')  AS codigo_entidade,
	             TRUE                           AS pasta_com_codigo
	      FROM   der_ce_medicao.medicoes_obras tab
	      -- -----------------------------------------------------------------------
	      -- Entidade: 113 - OBRFIN - Financeiro Medicao Obra
	      UNION ALL 
	      SELECT tab.id_tipo_entidade,
	             tab.id_entidade,
	             tab.id_entidade_pai,
	             tab.codigo_entidade,                
	             tab.pasta_com_codigo
	      FROM   documento_digital.vw_lista_id_tipo_entidade_despesa tab
	      WHERE tab.id_tipo_entidade = 113
	      -- =======================================================================
	      -- >>>     ENTIDADES RELACIONADA A CONSERVACAO RODOVIARIA              <<<
	      -- =======================================================================
	      -- Entidade: 122 - CONMED - Medição da Conserva Rodoviaria
	      UNION ALL 
	      SELECT 122                            AS id_tipo_entidade,
	             tab.id                         AS id_entidade,
	             tab.id_contrato                AS id_entidade_pai,  
	             to_char(tab.nr_medicao,'000')  AS codigo_entidade,
	             TRUE                           AS pasta_com_codigo
	      FROM   controle_conservacao.medicoes  tab	      
	      -- -----------------------------------------------------------------------
	      -- Entidade: 123 - CONFIN - Financeiro Medicao Conserva Rodoviaria
	      UNION ALL 
	      SELECT tab.id_tipo_entidade,
	             tab.id_entidade,
	             tab.id_entidade_pai,
	             tab.codigo_entidade,                
	             tab.pasta_com_codigo
	      FROM   documento_digital.vw_lista_id_tipo_entidade_despesa tab
	      WHERE tab.id_tipo_entidade = 123
	      -- =======================================================================
	      -- >>>     ENTIDADES RELACIONADA A SUPERVISÃO de OBRAS RODOVIARIA      <<<
	      -- =======================================================================
	      -- Entidade: 130 - CTRSUP - Contrato de Supervisao
	      UNION ALL 
	      SELECT 130                 AS id_tipo_entidade,
	             tab.id_contrato     AS id_entidade,
	             tab.id_contrato     AS id_entidade_pai,
	             ctr.nr_contrato_der AS codigo_entidade,
	             FALSE               AS pasta_com_codigo
	      FROM   der_ce_supervisao_new.planilha_supervisao_contratada tab
	      JOIN   der_ce_contrato.contratos                            ctr ON ctr.id = tab.id_contrato
	      -- -----------------------------------------------------------------------
	      -- Entidade: 131 - SUPPLA - Planilha de Supervisão
	      UNION ALL 
	      SELECT 131                 AS id_tipo_entidade,
	             tab.id_contrato     AS id_entidade,
	             tab.id_contrato     AS id_entidade_pai,
	             ctr.nr_contrato_der AS codigo_entidade,
	             FALSE               AS pasta_com_codigo
	      FROM   der_ce_supervisao_new.planilha_supervisao_contratada tab
	      JOIN   der_ce_contrato.contratos                            ctr ON ctr.id = tab.id_contrato
	      -- -----------------------------------------------------------------------
	      -- Entidade: 132 - SUPMED - Medição da Supervisão de Obra de Rodovias
	      UNION ALL 
	      SELECT 132                            AS id_tipo_entidade,
	             tab.id                         AS id_entidade,
	             tab.id_planilha                AS id_entidade_pai,  
	             to_char(tab.nr_medicao,'000')  AS codigo_entidade,
	             TRUE                           AS pasta_com_codigo
	      FROM   der_ce_supervisao_new.medicoes_supervisao tab	      
	      -- -----------------------------------------------------------------------
	      -- Entidade: 133 - SUPFIN - Financeiro das Supervisões de Obras
	      UNION ALL 
	      SELECT tab.id_tipo_entidade,
	             tab.id_entidade,
	             tab.id_entidade_pai,
	             tab.codigo_entidade,                
	             tab.pasta_com_codigo
	      FROM   documento_digital.vw_lista_id_tipo_entidade_despesa tab
	      WHERE tab.id_tipo_entidade = 133	      
	      -- =======================================================================
	      -- >>>    ENTIDADES RELACIONADA A CONTRATOS DO SIGSOP-EDIFICAÇÕES      <<<
	      -- =======================================================================
	      -- Entidade: 200 - CTRDEE - Contrato de Despesa Edificações
	      UNION ALL
	      SELECT 200                 AS id_tipo_entidade,
	             tab.id              AS id_entidade,
	             NULL                AS id_entidade_pai,
	             tab.nr_contrato_der AS codigo_entidade,
	             TRUE                AS pasta_com_codigo
	      FROM   dae_ce_contrato.contratos tab
	      -- -----------------------------------------------------------------------
	      -- Entidade: 201 - CTRADT - Aditivos de Contrato (Edificações)
	      UNION ALL
	      SELECT 201                 AS id_tipo_entidade,
	             tab.id              AS id_entidade,
	             tab.id_contrato     AS id_entidade_pai,
	             tab.nr_protocolo    AS codigo_entidade,
	             FALSE               AS pasta_com_codigo
	      FROM   dae_ce_contrato.aditivos tab	            
	      -- =======================================================================
	      -- >>>           ENTIDADES RELACIONADA A OBRAS EDIFICAÇÔES             <<<
	      -- =======================================================================
	      -- Entidade: 210 - CTROBE - Contrato Tipo 6: Obra (Edificações)
	      -- Entidade: 220 - CTRMAE - Contrato Tipo 7: Manutenção (Edificações)
	      UNION ALL 
	      SELECT CASE WHEN ctr.tipo = 7 THEN 220 ELSE 210 END AS id_tipo_entidade, 
	             tab.id          AS id_entidade,
	             tab.id_contrato AS id_entidade_pai,
	             tab.codigo_obra AS codigo_entidade,
	             TRUE            AS pasta_com_codigo
	      FROM   dae_ce_obra.obras             tab
	      JOIN   dae_ce_contrato.contratos     ctr ON ctr.id = tab.id_contrato
	      -- -----------------------------------------------------------------------
	      -- Entidade: 211 - OBEORC - Orçamento da Obra (Edificações)
	      -- Entidade: 221 - MAEORC - Orçamento da Manutenção (Edificações)
	      UNION ALL 
	      SELECT CASE WHEN ctr.tipo = 7 THEN 221 ELSE 211 END AS id_tipo_entidade, 
	             tab.id          AS id_entidade,
	             tab.id_obra     AS id_entidade_pai,
	             obr.codigo_obra AS codigo_entidade,
	             FALSE           AS pasta_com_codigo
	      FROM   dae_ce_orcamento.orcamentos   tab
	      JOIN   dae_ce_obra.obras             obr ON obr.id = tab.id_obra
	      JOIN   dae_ce_contrato.contratos     ctr ON ctr.id = obr.id_contrato
	      -- -----------------------------------------------------------------------
	      -- Entidade: 212 - OBEMED - Medição da Obra (Edificações)
	      -- Entidade: 222 - MAEMED - Medição da Mantenção (Edificações)
	      UNION ALL 
	      SELECT CASE WHEN ctr.tipo = 7 THEN 222 ELSE 212 END AS id_tipo_entidade, 
	             tab.id                         AS id_entidade,
	             tab.id_obra                    AS id_entidade_pai,  
	             to_char(tab.nr_medicao,'000')  AS codigo_entidade,
	             TRUE                           AS pasta_com_codigo
	      FROM   dae_ce_medicao.medicoes_obras tab
	      JOIN   dae_ce_obra.obras             obr ON obr.id = tab.id_obra
	      JOIN   dae_ce_contrato.contratos     ctr ON ctr.id = obr.id_contrato
	      -- -----------------------------------------------------------------------
	      -- Entidade: 213 - OBEFIN - Financeiro Medicao Obra (Edificações)
	      -- Entidade: 223 - MAEFIN - Financeiro Manutenção Predial (Edificações)
	      UNION ALL 
	      SELECT tab.id_tipo_entidade,
	             tab.id_entidade,
	             tab.id_entidade_pai,
	             tab.codigo_entidade,                
	             tab.pasta_com_codigo
	      FROM   documento_digital.vw_lista_id_tipo_entidade_despesa tab
	      WHERE  tab.id_tipo_entidade IN (223,213)
	      -- -----------------------------------------------------------------------
	      -- Entidade: 150 - PREADR - Medição da Supervisão de Obra de Rodovias
          UNION ALL
          SELECT 150    AS id_tipo_entidade,
                 mad.id AS id_entidade,
                 ctr.id AS id_entidade_pai,
                 'ID' || RIGHT('00000' || mad.id, 6) AS codigo_entidade,
                 TRUE   AS pasta_com_codigo
            FROM gestao_contratos.manifestacao_aditivo mad
            JOIN gestao_contratos.contrato_situacao    cst ON cst.id = mad.id_contrato_situacao
            JOIN der_ce_contrato.contratos             ctr ON ctr.id = cst.id_contrato 
                                                          AND cst.origem_contrato = 'RODOVIAS'::text
	      -- -----------------------------------------------------------------------
	      -- Entidade: 250 - PREADE - Medição da Supervisão de Obra de Rodovias
          UNION ALL
          SELECT 250 AS id_tipo_entidade,
                 mad.id AS id_entidade,
                 ctr.id AS id_entidade_pai,
                 'ID' || RIGHT('00000' || mad.id, 6) AS codigo_entidade,
                 TRUE   AS pasta_com_codigo
          FROM gestao_contratos.manifestacao_aditivo mad
          JOIN gestao_contratos.contrato_situacao    cst ON cst.id = mad.id_contrato_situacao
          JOIN dae_ce_contrato.contratos             ctr ON ctr.id = cst.id_contrato 
                                                        AND cst.origem_contrato = 'EDIFICACOES'::text
	      -- -----------------------------------------------------------------------
	      -- Entidade: 550 - EMPCTD - Empresas Contratadas
          UNION ALL
          SELECT 550           AS id_tipo_entidade,
                 ctt.id_pessoa AS id_entidade,
                 NULL::integer AS id_entidade_pai,
                 ctt.cnpj      AS codigo_entidade,
                 TRUE          AS pasta_com_codigo
          FROM der_ce_coorporativo.pessoas_juridicas ctt
	      -- -----------------------------------------------------------------------
	      -- Entidade: 551 - CTDACT - Atestado de Capacidade Técnica
          UNION ALL
          SELECT 551               AS id_tipo_entidade,
                 act.id            AS id_entidade,
                 act.id_contratada AS id_entidade_pai,
                 act.codigo        AS codigo_entidade,
                 FALSE             AS pasta_com_codigo
          FROM der_ce_controle_certidao.act_documentos act
	      -- -----------------------------------------------------------------------
	      -- Entidade: 390 - CONVENIO - Convênio Digital
         UNION ALL
         SELECT 390           AS id_tipo_entidade,
                1             AS id_entidade,
                NULL::integer AS id_entidade_pai,
                ''::character varying AS codigo_entidade,
                FALSE         AS pasta_com_codigo
	      -- -----------------------------------------------------------------------
	      -- Entidade: 395 - PREFEITURA - Prefeitura
         UNION ALL
         SELECT 395          AS id_tipo_entidade,
                pj.id_pessoa AS id_entidade,
                1            AS id_entidade_pai,
                pj.cnpj      AS codigo_entidade,
                true         AS pasta_com_codigo
         FROM der_ce_coorporativo.pessoas_juridicas pj
         WHERE pj.id_tipo_pessoa_juridica = 1
	      -- -----------------------------------------------------------------------
	      -- Entidade: 397 - PREFEITO - Prefeito
         UNION ALL
         SELECT 397          AS id_tipo_entidade,
                p.id         AS id_entidade,
                pj.id_pessoa AS id_entidade_pai,
                p.cpf        AS codigo_entidade,
                true         AS pasta_com_codigo
         FROM convenios.prefeito p
              JOIN der_ce_coorporativo.pessoas_juridicas pj ON pj.id_pessoa = p.id_prefeitura
         WHERE pj.id_tipo_pessoa_juridica = 1
	      -- -----------------------------------------------------------------------
	      -- Entidade: 400 - CVNSOP - Convênio SOP
         UNION ALL
         SELECT 400             AS id_tipo_entidade,
                c.id            AS id_entidade,
                c.id_convenente AS id_entidade_pai,
                'ID'::text || "right"('00000'::text || c.id::text, 6) AS codigo_entidade,
                true            AS pasta_com_codigo
         FROM convenios.convenio c
	      -- -----------------------------------------------------------------------
	      -- Entidade: 410 - CVNSOP - Convênio SOP
         UNION ALL
         SELECT 410     AS id_tipo_entidade,
                clb.id  AS id_entidade,
                cvn.id  AS id_entidade_pai,
                ''::character varying AS codigo_entidade,
                false   AS pasta_com_codigo
         FROM convenios.celebracao clb
         JOIN convenios.convenio   cvn ON cvn.id = clb.id_convenio              
        -- -----------------------------------------------------------------------
	    ) qry;
	    
--------------------------------------------------------------------------------
-- VIEW....: documento_digital.vw_lista_id_assinadores 
-- CLASSE..: der.ce.documento_digital.VoListIdAssinadores.java
-- Objetivo: Utilizado para Montar o caminho onde do repositório onde os arquivos serão armazenados
--------------------------------------------------------------------------------  
CREATE OR REPLACE VIEW documento_digital.vw_lista_id_assinadores AS
    SELECT row_number() OVER () AS id, 
           dxa.id_tipo_documento,
           dxa.id_tipo_assinador,
           CASE WHEN tas.tipo = 1 -- 1-Statico
                THEN tas.id_assinador
                ELSE adi.id_assinador
           END AS id_assinador,
           adi.cpf_assinador,
           adi.id_entidade    
    FROM documento_digital.tipo_documento_x_tipo_assinador dxa
    JOIN documento_digital.tipo_assinador                  tas ON tas.id = dxa.id_tipo_assinador
    -- -----------------------------------------------------------------------------
    JOIN -- Recupera Assinadores Dinamico
    -- -----------------------------------------------------------------------------
    (SELECT 4             AS id_tipo_assinador, -- 4 = ASSINADOR_CONTRATANTE
            tb1.id_pessoa AS id_entidade,
            tb1.cnpj      AS id_assinador,
            null          AS cpf_assinador
       FROM der_ce_coorporativo.pessoas_juridicas tb1 
      WHERE tb1.id_tipo_pessoa_juridica = 2 -- 2-Orgão Estadual
     -- ----------------------------------------------------------------------------
     UNION ALL
     SELECT 5             AS id_tipo_assinador, -- 5 = ASSINADOR_CONTRATADA
            tb1.id_pessoa AS id_entidade,
            tb1.cnpj      AS id_assinador,
            null          AS cpf_assinador
       FROM der_ce_coorporativo.pessoas_juridicas tb1 
      WHERE tb1.id_tipo_pessoa_juridica = 4 -- 4-Empresas
     -- ----------------------------------------------------------------------------
     UNION ALL
     SELECT 6             AS id_tipo_assinador, -- 6 = ASSINADOR_SUPERVISORA
            tb1.id_pessoa AS id_entidade,
            tb1.cnpj      AS id_assinador,
            null          AS cpf_assinador
       FROM der_ce_coorporativo.pessoas_juridicas tb1 
      WHERE tb1.id_tipo_pessoa_juridica = 4 -- 4-Empresas
     -- ----------------------------------------------------------------------------
     UNION ALL
     SELECT 102            AS id_tipo_assinador, -- 102 = ASSINADOR_FISCAL_OBRA_RODOVIARIA
            tb1.id         AS id_entidade,
            tb2.id_fiscal  AS id_assinador,
            tb4.cpf        AS cpf_assinador
       FROM der_ce_medicao.medicoes_obras         tb1
       JOIN der_ce_medicao.medicoes_obras_fiscais tb2 ON tb1.id        = tb2.id_medicao 
       JOIN der_ce_coorporativo.funcionarios      tb3 ON tb2.id_fiscal = tb3.matricula
       JOIN der_ce_coorporativo.pessoas_fisicas   tb4 ON tb4.id_pessoa = tb3.id_pessoa_fisica
      WHERE tb2.id_tipo = 2 -- 2 - 1o Membro da Comissão
     -- ----------------------------------------------------------------------------
     UNION ALL
     SELECT 103            AS id_tipo_assinador, -- 103 = ASSINADOR_FISCAL_SUPERVISAO_OBRAS
            tb1.id         AS id_entidade,
            tb2.id_fiscal  AS id_assinador,
            tb4.cpf        AS cpf_assinador
       FROM der_ce_supervisao_new.medicoes_supervisao tb1
       JOIN der_ce_supervisao_new.supervisao_fiscais  tb2 ON tb1.id_planilha = tb2.id_contrato 
       JOIN der_ce_coorporativo.funcionarios          tb3 ON tb2.id_fiscal   = tb3.matricula
       JOIN der_ce_coorporativo.pessoas_fisicas       tb4 ON tb4.id_pessoa   = tb3.id_pessoa_fisica
      WHERE tb2.id_tipo = 2 -- 2 - 1o Membro da Comissão
     -- ----------------------------------------------------------------------------
     UNION ALL
       SELECT 104            AS id_tipo_assinador, -- 104 = ASSINADOR_FISCAL_OBRA_SUPERVISIONADA
            tb1.id_medicao AS id_entidade,
            tb2.id_fiscal  AS id_assinador,
            tb4.cpf        AS cpf_assinador
       FROM der_ce_supervisao_new.medicoes_supervisao_obra tb1
       JOIN der_ce_obra.obras_fiscais                      tb2 ON tb1.id_obra   = tb2.id_obra 
       JOIN der_ce_coorporativo.funcionarios               tb3 ON tb2.id_fiscal = tb3.matricula
       JOIN der_ce_coorporativo.pessoas_fisicas            tb4 ON tb4.id_pessoa = tb3.id_pessoa_fisica
      WHERE tb2.id_tipo = 2 -- 2 - 1o Membro da Comissão  
     -- ----------------------------------------------------------------------------
     UNION ALL
     SELECT 105            AS id_tipo_assinador, -- 105 = ASSINADOR_COMISSAO_OBRA_RODOVIARIA (Na Medição)
            tb1.id         AS id_entidade,
            tb2.id_fiscal  AS id_assinador,
            tb4.cpf        AS cpf_assinador
       FROM der_ce_medicao.medicoes_obras         tb1
       JOIN der_ce_medicao.medicoes_obras_fiscais tb2 ON tb1.id        = tb2.id_medicao 
       JOIN der_ce_coorporativo.funcionarios      tb3 ON tb2.id_fiscal = tb3.matricula
       JOIN der_ce_coorporativo.pessoas_fisicas   tb4 ON tb4.id_pessoa = tb3.id_pessoa_fisica
     -- ----------------------------------------------------------------------------
     UNION ALL
     SELECT 106            AS id_tipo_assinador, -- 106 = ASSINADOR_COMISSAO_OBRA_RODOVIARIA (Na Obra)
            tb1.id         AS id_entidade,
            tb2.id_fiscal  AS id_assinador,
            tb4.cpf        AS cpf_assinador
       FROM der_ce_obra.obras                   tb1
       JOIN der_ce_obra.obras_fiscais           tb2 ON tb1.id        = tb2.id_obra
       JOIN der_ce_coorporativo.funcionarios    tb3 ON tb2.id_fiscal = tb3.matricula
       JOIN der_ce_coorporativo.pessoas_fisicas tb4 ON tb4.id_pessoa = tb3.id_pessoa_fisica
     -- ----------------------------------------------------------------------------
     UNION ALL
     SELECT 107            AS id_tipo_assinador, -- 106 = ASSINADOR_COMISSAO_SUPERVISAO_OBRAS
            tb1.id         AS id_entidade,
            tb2.id_fiscal  AS id_assinador,
            tb4.cpf        AS cpf_assinador
       FROM der_ce_supervisao_new.medicoes_supervisao tb1
       JOIN der_ce_supervisao_new.supervisao_fiscais  tb2 ON tb1.id_planilha = tb2.id_contrato 
       JOIN der_ce_coorporativo.funcionarios          tb3 ON tb2.id_fiscal   = tb3.matricula
       JOIN der_ce_coorporativo.pessoas_fisicas       tb4 ON tb4.id_pessoa   = tb3.id_pessoa_fisica
-- ----------------------------------------------------------------------------
     UNION ALL
     SELECT 109                        AS id_tipo_assinador, -- 109-DIRETORIA_OBRA_RODOVIARIA
            act.id                     AS id_entidade,
            sro.matricula_coordenador  AS id_assinador,
            sro.cpf_coorenador         AS cpf_assinador
       FROM der_ce_controle_certidao.act_documentos act
       JOIN der_ce_controle_certidao.certidoes      cer ON cer.id = act.id_act_origem 
       JOIN der_ce_obra.obras                       obr ON obr.id = cer.id_obra
       JOIN der_ce_obra.setor_responsavel_obra      sro ON sro.id = obr.id_setor_responsavel
      WHERE act.id_tipo_act = 55101 -- ACT_Obras
     -- ----------------------------------------------------------------------------
     UNION ALL
     SELECT 110                        AS id_tipo_assinador, -- 110-DIRETORIA_CONSERVA_RODOVIARIA
            act.id                     AS id_entidade,
            sro.matricula_coordenador  AS id_assinador,
            sro.cpf_coorenador         AS cpf_assinador
       FROM der_ce_controle_certidao.act_documentos act
       JOIN der_ce_controle_certidao.certidoes      cer ON cer.id = act.id_act_origem 
       JOIN der_ce_obra.setor_responsavel_obra      sro ON sro.id = 1 -- DIRAE / GEMAV
      WHERE act.id_tipo_act = 55102 -- ACT_Conserva
     -- ----------------------------------------------------------------------------
     UNION ALL
     SELECT 111                        AS id_tipo_assinador, -- 111-DIRETORIA_SUPERVISAO_RODOVIARIA
            act.id                     AS id_entidade,
            sro.matricula_coordenador  AS id_assinador,
            sro.cpf_coorenador         AS cpf_assinador
       FROM der_ce_controle_certidao.act_documentos              act
       JOIN der_ce_controle_certidao.certidoes                   cer ON cer.id = act.id_act_origem 
       JOIN der_ce_supervisao_new.planilha_supervisao_contratada psc ON psc.id_contrato = cer.id_contrato     
       JOIN der_ce_obra.setor_responsavel_obra                   sro ON sro.id = psc.id_setor_responsavel
      WHERE act.id_tipo_act = 55103 -- ACT_Supervisão
	       -- ----------------------------------------------------------------------------
     UNION ALL
     SELECT 113           AS id_tipo_assinador, -- 113-FISCAL_CONSERVA_RODOVIARIA
            tb1.id        AS id_entidade,
            tb2.id_fiscal AS id_assinador,
            tb4.cpf       AS cpf_assinador
       FROM controle_conservacao.medicoes         tb1
       JOIN controle_conservacao.medicoes_fiscais tb2 ON tb1.id        = tb2.id_medicao
       JOIN der_ce_coorporativo.funcionarios      tb3 ON tb2.id_fiscal = tb3.matricula
       JOIN der_ce_coorporativo.pessoas_fisicas   tb4 ON tb4.id_pessoa = tb3.id_pessoa_fisica
      WHERE tb2.id_tipo_fiscal = 2 -- 2 - 1o Membro da Comissão  
       -- ----------------------------------------------------------------------------
     UNION ALL
     SELECT 114           AS id_tipo_assinador, -- 114-COMISSAO_CONSERVA_RODOVIAS
            tb1.id        AS id_entidade,
            tb2.id_fiscal AS id_assinador,
            tb4.cpf       AS cpf_assinador
       FROM controle_conservacao.medicoes         tb1
       JOIN controle_conservacao.medicoes_fiscais tb2 ON tb1.id        = tb2.id_medicao
       JOIN der_ce_coorporativo.funcionarios      tb3 ON tb2.id_fiscal = tb3.matricula
       JOIN der_ce_coorporativo.pessoas_fisicas   tb4 ON tb4.id_pessoa = tb3.id_pessoa_fisica
     -- ---------------------------------------------------------------------------     
     UNION ALL
     SELECT 202     AS id_tipo_assinador, -- 202 = ASSINADOR_FISCAL_OBRA_EDIFICACOES
            tb1.id  AS id_entidade,
            CASE WHEN mfi.id_entidade ISNULL THEN ofi.id_assinador  ELSE mfi.id_assinador  END AS id_assinador,
            CASE WHEN mfi.id_entidade ISNULL THEN ofi.cpf_assinador ELSE mfi.cpf_assinador END AS cpf_assinador
       FROM dae_ce_medicao.medicoes_obras       tb1
       LEFT JOIN (-- Recupera fiscal da Medição que Validou a Medição
            SELECT tb1.id             AS id_entidade,
                    tb2.id_funcionario AS id_assinador,
                    tb4.cpf            AS cpf_assinador
               FROM dae_ce_medicao.medicoes_obras       tb1
               JOIN dae_ce_medicao.medicao_fiscal       tb2 ON tb1.id             = tb2.id_medicao 
               JOIN der_ce_coorporativo.funcionarios    tb3 ON tb2.id_funcionario = tb3.matricula
               JOIN der_ce_coorporativo.pessoas_fisicas tb4 ON tb4.id_pessoa      = tb3.id_pessoa_fisica
              WHERE tb2.validou_medicao -- Indica fiscal que validou a medição
                  ) mfi ON tb1.id = mfi.id_entidade 
       LEFT JOIN (-- Recupera Fiscal da Obra do tipo: 1o Membro 10-Fiscal
            SELECT tb1.id             AS id_entidade,
                   tb2.id_fiscal      AS id_assinador,
                   tb4.cpf            AS cpf_assinador
              FROM dae_ce_medicao.medicoes_obras       tb1
              JOIN dae_ce_obra.obras                   tbo ON tbo.id         = tb1.id_obra
              JOIN dae_ce_obra.obras_fiscais           tb2 ON tbo.id         = tb2.id_obra   AND tbo.id_portaria_atual = tb2.id_portaria 
              JOIN der_ce_coorporativo.funcionarios    tb3 ON tb2.id_fiscal  = tb3.matricula
              JOIN der_ce_coorporativo.pessoas_fisicas tb4 ON tb4.id_pessoa  = tb3.id_pessoa_fisica
             WHERE tb2.id_tipo IN (2,10)  -- 2-1o Membro 10-Fiscal
                 ) ofi ON tb1.id = Ofi.id_entidade 
      -- ---------------------------------------------------------------------------
      UNION ALL
      SELECT 203               AS id_tipo_assinador, -- 203 = ASSINADOR_FISCAL_MANUTENCAO_EDIFICACOES
            tb1.id             AS id_entidade,
            tb2.id_funcionario AS id_assinador,
            tb4.cpf            AS cpf_assinador
       FROM dae_ce_medicao.medicoes_obras       tb1
       JOIN dae_ce_medicao.medicao_fiscal       tb2 ON tb1.id             = tb2.id_medicao 
       JOIN der_ce_coorporativo.funcionarios    tb3 ON tb2.id_funcionario = tb3.matricula
       JOIN der_ce_coorporativo.pessoas_fisicas tb4 ON tb4.id_pessoa      = tb3.id_pessoa_fisica
      WHERE tb2.validou_medicao -- Indica fiscal que validou a medição
      -- ---------------------------------------------------------------------------     
      UNION ALL
      SELECT 204               AS id_tipo_assinador, -- 204 = ASSINADOR_COMISSAO_OBRA_EDIFICACOES
            tb1.id             AS id_entidade,
            tb2.id_funcionario AS id_assinador,
            tb4.cpf            AS cpf_assinador
       FROM dae_ce_medicao.medicoes_obras       tb1
       JOIN dae_ce_medicao.medicao_fiscal       tb2 ON tb1.id             = tb2.id_medicao 
       JOIN der_ce_coorporativo.funcionarios    tb3 ON tb2.id_funcionario = tb3.matricula
       JOIN der_ce_coorporativo.pessoas_fisicas tb4 ON tb4.id_pessoa      = tb3.id_pessoa_fisica
      -- ---------------------------------------------------------------------------
      UNION ALL
      SELECT 205               AS id_tipo_assinador, -- 205 = ASSINADOR_COMISSAO_MANUTENCAO_EDIFICACOES
            tb1.id             AS id_entidade,
            tb2.id_funcionario AS id_assinador,
            tb4.cpf            AS cpf_assinador
       FROM dae_ce_medicao.medicoes_obras tb1
       JOIN dae_ce_medicao.medicao_fiscal       tb2 ON tb1.id             = tb2.id_medicao 
       JOIN der_ce_coorporativo.funcionarios    tb3 ON tb2.id_funcionario = tb3.matricula
       JOIN der_ce_coorporativo.pessoas_fisicas tb4 ON tb4.id_pessoa      = tb3.id_pessoa_fisica
      -- ---------------------------------------------------------------------------
      UNION ALL
      SELECT 405          AS id_tipo_assinador, -- 405 = RESPONSAVEL_TECNICO
            tb1.id_pessoa AS id_entidade,
            tb1.cnpj      AS id_assinador,
            NULL::text    AS cpf_assinador
       FROM der_ce_coorporativo.pessoas_juridicas tb1
      WHERE tb1.id_tipo_pessoa_juridica = 1 -- 1-Prefeituras
      -- ---------------------------------------------------------------------------
        UNION ALL
         SELECT 406       AS id_tipo_assinador, -- 206 = CONVENENTE
            tb1.id_pessoa AS id_entidade,
            tb1.cnpj      AS id_assinador,
            NULL::text    AS cpf_assinador
           FROM der_ce_coorporativo.pessoas_juridicas tb1
          WHERE tb1.id_tipo_pessoa_juridica = 1 -- 1-Prefeituras
    ) adi ON tas.id = adi.id_tipo_assinador;
   
   
-- ---------------------------------------------------------------------
-- Exclui assinaturas anteriores das funções
-- ---------------------------------------------------------------------
DROP VIEW documento_digital.vw_dados_medicoes_por_assinador_nao_assinadas;
DROP FUNCTION documento_digital.fn_dados_despacho_atual(varchar, integer);
DROP FUNCTION documento_digital.fn_dados_medicoes(varchar, integer);

-- --------------------------------------------------------------------------
-- FUNÇÂO..: documento_digital.fn_doc_dados_medicoes ()
-- OBJETIVO: Retorna uma lista de dados de uma medição
-- PARAM...: [id_entidade       -> Id Da medição a ser recupérada
--           [id_tipo_entidade] -> Id do tipo de medição (Obra/Manutenção/Conserva...)
-- --------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION documento_digital.fn_doc_retorna_dados_medicoes (
  var_id_entidade      VARCHAR,
  var_id_tipo_entidade INTEGER
)
-- Lista de Atributos a serem retornados
RETURNS TABLE (
  id_tipo_entidade    INTEGER,
  id_entidade         INTEGER,
  id_tipo_contrato    INTEGER,
  tipo_contrato       VARCHAR,
  contrato_nr         VARCHAR,
  contrato_contratada VARCHAR,
  obra_codigo         VARCHAR,
  obra_descricao      VARCHAR,
  medicao_nr              INTEGER,
  medicao_periodo         TEXT,
  medicao_status          VARCHAR,
  medicao_nr_protocolo    VARCHAR,
  medicao_valor_protocolo NUMERIC
) AS
$body$
BEGIN
  RETURN QUERY  
  -- ------------------------------------------------------------------
  -- Recupera dados de Medições de EDIFICAÇÔES (OBRA/MANUTENÇÂO)
  SELECT CASE WHEN tco.id_tipo_contrato = 6 THEN 212 -- 212 - Obras de Edificações
              WHEN tco.id_tipo_contrato = 7 THEN 222 -- 222 - Manutenção Predial
              ELSE NULL::integer
         END AS id_tipo_entidade,
         moe.id              AS id_entidade,
         tco.id_tipo_contrato,
         tco.descricao       AS tipo_contrato,   
         ctr.nr_contrato_ext AS contrato_nr,
         pju.nome_fantansia  AS contrato_contratada,
         obr.codigo_obra     AS obra_codigo,
         obr.descricao       AS obra_descricao,
         moe.nr_medicao      AS medicao_nr,
         to_char(moe.data_fim, 'MM/yyyy') AS medicao_periodo,
         stm.descricao       AS medicao_status,
         pro.nr_protocolo    AS medicao_nr_protocolo,
         CASE WHEN pro.id IS NOT NULL 
              THEN pro.valor_processo
              ELSE moe.valor_medicao
         END AS medicao_valor_protocolo
  FROM dae_ce_medicao.medicoes_obras                moe
  JOIN dae_ce_medicao.status_medicao                stm ON stm.id = moe.id_status
  JOIN dae_ce_obra.obras                            obr ON obr.id = moe.id_obra
  JOIN dae_ce_contrato.contratos                    ctr ON ctr.id = obr.id_contrato
  JOIN documento_digital.vw_tipo_contrato_sop       tco ON tco.id_tipo_contrato = ctr.tipo
  JOIN der_ce_coorporativo.pessoas_juridicas        pju ON pju.id_pessoa = ctr.id_contratada
  LEFT JOIN dae_ce_medicao.processos_medicoes_obras pro ON moe.id = pro.id_medicao
  WHERE moe.id::text = var_id_entidade -- $1 
  
  -- -----------------------------------------------------------------
  -- Recupera dados de Medições de OBRAS de RODOVIAS
  UNION ALL
  SELECT 112                  AS id_tipo_entidade, -- 112 - Medições de Obras de Rodovias
         mor.id               AS id_entidade,
         tco.id_tipo_contrato,
         tco.descricao        AS tipo_contrato,   
         ctr.nr_contrato_ext  AS contrato_nr,
         pju.nome_fantansia   AS contrato_contratada,
         obr.codigo_obra      AS obra_codigo,
         obr.descricao        AS obra_descricao,
         mor.nr_medicao       AS medicao_nr,
         RIGHT(per.ano_mes, 2) || '/' || 
         LEFT(per.ano_mes, 4) AS medicao_periodo,
         stm.descricao        AS medicao_status,
         pro.nr_protocolo     AS medicao_nr_protocolo,
         pro.valor_processo   AS medicao_valor_protocolo
  FROM der_ce_medicao.medicoes_obras                mor
  JOIN der_ce_medicao.status_medicao                stm ON stm.id = mor.id_status
  JOIN der_ce_medicao.periodos_medicoes_obras       per ON per.id = mor.id_periodo
  JOIN der_ce_obra.obras                            obr ON obr.id = mor.id_obra
  JOIN der_ce_contrato.contratos                    ctr ON ctr.id = obr.id_contrato
  JOIN documento_digital.vw_tipo_contrato_sop       tco ON tco.id_tipo_contrato = ctr.tipo
  JOIN der_ce_coorporativo.pessoas_juridicas        pju ON pju.id_pessoa = ctr.id_contratada           
  LEFT JOIN der_ce_medicao.processos_medicoes_obras pro ON mor.id = pro.id_medicao
  WHERE mor.id::text = var_id_entidade -- $1
    AND 112 = var_id_tipo_entidade     -- $2
  
  -- -----------------------------------------------------------------
  -- Recupera dados de Medições de CONSERVA
  UNION ALL
  SELECT 122                  AS id_tipo_entidade, --  122 - CONSERVA
         moc.id               AS id_entidade,
         tco.id_tipo_contrato,
         tco.descricao        AS tipo_contrato,   
         ctr.nr_contrato_der  AS contrato_nr,
         pju.nome_fantansia   AS contrato_contratada,
         ''                   AS obra_codigo,
         ctr.objet          AS obra_descricao,
         moc.nr_medicao       AS medicao_nr,
         RIGHT(per.ano_mes, 2) || '/' || 
         LEFT(per.ano_mes, 4) AS medicao_periodo,
         stm.descricao        AS medicao_status,
         moc.nr_protocolo     AS medicao_nr_protocolo,
         moc.valor_processo   AS medicao_valor_protocolo
		FROM controle_conservacao.medicoes              moc  
		JOIN controle_conservacao.status_medicao_fisico stm ON stm.id = moc.id_status_fisico
		JOIN der_ce_medicao.periodos_medicoes_obras     per ON per.id = moc.id_periodo
		JOIN der_ce_contrato.contratos                  ctr ON ctr.id = moc.id_contrato 
		JOIN documento_digital.vw_tipo_contrato_sop     tco ON tco.id_tipo_contrato = ctr.tipo
		JOIN der_ce_coorporativo.pessoas_juridicas      pju ON pju.id_pessoa = ctr.id_contratada
		WHERE moc.id::text = var_id_entidade -- $1
          AND 122 = var_id_tipo_entidade;    -- $2
  END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER COST 100 ROWS 1000;

-- --------------------------------------------------------------------------
-- FUNÇÂO..: documento_digital.fn_doc_dados_medicoes ()
-- OBJETIVO: Retorna uma lista de dados de uma medição
-- PARAM...: [id_entidade       -> Id Da medição a ser recupérada
--           [id_tipo_entidade] -> Id do tipo de medição (Obra/Manutenção/Conserva...)
-- --------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION documento_digital.fn_doc_retorna_dados_despacho_atual (
  var_id_origem      TEXT,   -- Id da Entidade ou da Medição
  var_id_tipo_origem INTEGER -- Id Tipo Entidade ou Tipo Medição
)
-- Lista de Atributos a serem retornados
RETURNS TABLE (
  setor_atual      VARCHAR(10),
  nr_tramitacao    INTEGER,
  status_descricao VARCHAR,
  dth_inicio       TIMESTAMP,
  dth_fim          TIMESTAMP,
  tempo_corrido_tramitacao TEXT
) AS
$body$
BEGIN
  RETURN QUERY     
  SELECT CASE WHEN tra.id_status = 3  -- 3-Aguardando Recebimento
              THEN std.sigla
              ELSE sto.sigla
         END AS setor_atual,
         tra.nr_tramitacao,
         str.descricao AS status_descricao,
         tct.dth_inicio,
         tct.dth_fim,
    date_part('days'   ,tct.tempo_corrido_tramitacao) || ' dia(s) '  || 
    date_part('hours'  ,tct.tempo_corrido_tramitacao) || ' hora(s) ' || 
    date_part('minutes',tct.tempo_corrido_tramitacao) || ' minuto(s) ' AS tempo_corrido_tramitacao
  FROM controle_despachos.despachos           des
  JOIN controle_despachos.tramitacoes         tra ON tra.id = des.id_tramitacao_atual
  JOIN controle_despachos.status_tramitacao   str ON str.id = tra.id_status
  JOIN controle_despachos.vw_setores_sop      sto ON sto.id = tra.id_setor_origem
  LEFT JOIN controle_despachos.vw_setores_sop std ON std.id = tra.id_setor_destino
  JOIN controle_despachos.vw_tempo_corrido_tramitacao tct ON tra.id = tct.id_tramitacao
   WHERE des.id_origem::text = var_id_origem -- $1
     AND des.id_tipo_origem  = var_id_tipo_origem; -- $2
  END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER COST 100 ROWS 1000;

-- -----------------------------------------------------------------------
-- VIEW....: documento_digital.vw_documentos_assinadores_resumido
-- OBJETIVO: recupera lista de ids dos assinadores por entidade
-- -----------------------------------------------------------------------
CREATE OR REPLACE VIEW documento_digital.vw_documentos_assinadores_resumido AS
SELECT doc.id_entidade_coleta,
       max(doc.id_entidade_doc)         AS id_entidade_doc,
       max(doc.id_tipo_entidade_coleta) AS id_tipo_entidade_coleta,
       dda.id_assinador
  FROM documento_digital.documentos_digitais doc
  JOIN (SELECT dxa.id_documento, dxa.id_assinador
          FROM documento_digital.documentos_digitais_x_assinadores dxa) dda ON doc.id = dda.id_documento
 GROUP BY doc.id_entidade_coleta, dda.id_assinador;

-- -----------------------------------------------------------------------
-- VIEW....: documento_digital.vw_dados_medicoes_por_assinador_nao_assinadas
-- OBJETIVO: Retorna dados da Medição para assinadores com pendencia de assinatura
-- -----------------------------------------------------------------------
CREATE OR REPLACE VIEW documento_digital.vw_dados_medicoes_por_assinador_nao_assinadas AS
SELECT doc.id_entidade_coleta AS id,
       doc.id_tipo_entidade_coleta,
       doc.id_entidade_doc,
       doc.id_assinador,
       med.id_tipo_contrato,
       med.tipo_contrato,
       med.contrato_nr,
       med.contrato_contratada,
       med.obra_codigo,
       med.obra_descricao,
       med.medicao_nr,
       med.medicao_periodo,
       med.medicao_status,
       med.medicao_nr_protocolo,
       med.medicao_valor_protocolo,
       sde.setor_atual,
       sde.nr_tramitacao,
       sde.status_descricao AS status_tramitacao,
       sde.dth_inicio,
       sde.dth_fim,
       sde.tempo_corrido_tramitacao
  FROM documento_digital.vw_documentos_assinadores_nao_assinados_resumido doc
  JOIN LATERAL 
       documento_digital.fn_doc_retorna_dados_medicoes(doc.id_entidade_coleta, doc.id_tipo_entidade_coleta) 
       med(id_tipo_entidade, 
           id_entidade, 
           id_tipo_contrato, 
           tipo_contrato, 
           contrato_nr, 
           contrato_contratada, 
           obra_codigo, 
           obra_descricao, 
           medicao_nr, 
           medicao_periodo, 
           medicao_status, 
           medicao_nr_protocolo, 
           medicao_valor_protocolo
          ) ON true
  LEFT JOIN LATERAL 
       documento_digital.fn_doc_retorna_dados_despacho_atual(doc.id_entidade_coleta, doc.id_tipo_entidade_coleta) 
       sde(setor_atual,  
           nr_tramitacao, 
           status_descricao, 
           dth_inicio, 
           dth_fim, 
           tempo_corrido_tramitacao
          ) ON true;