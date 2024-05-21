-- /////////////////////////////////////////////////////////////////////////////
--
-- ALTERAÇÕES FEITA NO SCRIPT APÓS  A CRIAÇÃO DO BANCO DE PRODUÇÃO
--
-- /////////////////////////////////////////////////////////////////////////////

-- =============================================================================
--
-- INICIO: C R I A Ç Â O   d a s   T A B E L A S
--
-- =============================================================================
--DROP SCHEMA controle_conservacao CASCADE;

CREATE SCHEMA controle_conservacao;

-- =============================================================================
-- C R I A Ç Ã O   D A S   S E Q U E N C E
-- =============================================================================
CREATE SEQUENCE controle_conservacao.sq_medicoes             INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;
CREATE SEQUENCE controle_conservacao.sq_medicoes_historicos  INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;
CREATE SEQUENCE controle_conservacao.sq_medicoes_ajustes     INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;
CREATE SEQUENCE controle_conservacao.sq_medicoes_fora_padrao INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;
CREATE SEQUENCE controle_conservacao.sq_medicoes_fiscais     INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;
CREATE SEQUENCE controle_conservacao.sq_contratos_fiscais    INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;

-- =============================================================================
-- C R I A Ç Ã O   D A S   T A B E L A S
-- =============================================================================
CREATE TABLE controle_conservacao.status_medicao_fisico (
    id            INTEGER      NOT NULL,
    cor           VARCHAR(8)   NOT NULL,
    sigla         VARCHAR(3)   NOT NULL,
    descricao     varchar(50)  NOT NULL,
    especificacao varchar(255) NOT NULL
) WITHOUT OIDS;

CREATE TABLE controle_conservacao.status_medicao_financeiro (
    id            INTEGER      NOT NULL,
    cor           VARCHAR(8)   NOT NULL,
    sigla         VARCHAR(3)   NOT NULL,
    descricao     varchar(50)  NOT NULL,
    especificacao varchar(255) NOT NULL
) WITHOUT OIDS;

CREATE TABLE controle_conservacao.tipo_historico_medicoes (
  id        INTEGER      NOT NULL,
  descricao VARCHAR(100) NOT NULL
) WITH (oids = true);

CREATE TABLE controle_conservacao.medicoes (
    id_contrato                 INTEGER       NOT NULL,
    id                          INTEGER       NOT NULL DEFAULT 
                                nextval(('controle_conservacao.sq_medicoes')),
    nr_medicao                  INTEGER       NOT NULL,
    nr_protocolo                VARCHAR(25),
    data_hora_protocolo         TIMESTAMP,
    data_inicio                 DATE          NOT NULL,
    data_fim                    DATE          NOT NULL,
    -- Valores da Medição
    valor_medido                NUMERIC(16,2) DEFAULT 0,
    fator_reajuste              NUMERIC(10,4) DEFAULT 0, 
    valor_reajuste              NUMERIC(16,2) DEFAULT 0,
    valor_ref_glosa             NUMERIC(16,2) DEFAULT 0,
    valor_ajuste_contratual     NUMERIC(16,2) DEFAULT 0,
    valor_processo              NUMERIC(16,2) DEFAULT 0,
    descricao_glosa             VARCHAR(255),
    descricao_ajuste_contratual VARCHAR(255),
    obs_responsavel             VARCHAR(500),
    obs_fiscal                  VARCHAR(500),
    id_fora_padrao              INTEGER,
    id_periodo                  INTEGER       NOT NULL, -- Periodo ao qual a medição se refere (AAAAMM)
    id_periodo_vigencia         INTEGER,
    id_status_fisico            INTEGER       NOT NULL,
    id_status_financeiro        INTEGER       NOT NULL,
    id_pre_liquidacao           INTEGER,
    id_despacho                 INTEGER,
    id_despesa                  INTEGER,
    id_despesa_contrato_tipo1   INTEGER,
    id_despesa_contrato_tipo2   INTEGER,
    id_despesa_contrato_tipo3   INTEGER,
    doc_digitais_conferido      BOOLEAN NOT NULL DEFAULT FALSE,
    nr_recibo                   VARCHAR(20)
) WITHOUT OIDS;

COMMENT ON  TABLE controle_conservacao.medicoes  IS 'Armazena informações das medições de conservação rodoviaria.';
COMMENT ON COLUMN controle_conservacao.medicoes.id_contrato                 IS 'Id do contrato de conservação ao qual a medição se refere.';
COMMENT ON COLUMN controle_conservacao.medicoes.nr_medicao                  IS 'Número da Medição em cada mês seja ZERO ou de valor.';
COMMENT ON COLUMN controle_conservacao.medicoes.nr_protocolo                IS 'Número do protocolo da Medição, Obrigatório após a validação e conferencia dos documentos ';
COMMENT ON COLUMN controle_conservacao.medicoes.data_hora_protocolo         IS 'Data e Hora em que o protocolo foi criado no SUITE';
COMMENT ON COLUMN controle_conservacao.medicoes.data_inicio                 IS 'Data de início do período de medição da Conserva. Se Padrão = Tabela periodo de medição SOP';
COMMENT ON COLUMN controle_conservacao.medicoes.data_fim                    IS 'Data de término do período de medição da Conserva. Se Padrão = Tabela periodo de medição SOP';
COMMENT ON COLUMN controle_conservacao.medicoes.valor_medido                IS 'A) = Valor PI Medido';
COMMENT ON COLUMN controle_conservacao.medicoes.fator_reajuste              IS 'X) = Fator de reajuste aplicavel a VALOR PI';
COMMENT ON COLUMN controle_conservacao.medicoes.valor_reajuste              IS 'B) = Valor de reajuste referente a Medição';
COMMENT ON COLUMN controle_conservacao.medicoes.valor_ref_glosa             IS 'C) = Valor referente a glosa de medições anteriores';
COMMENT ON COLUMN controle_conservacao.medicoes.valor_ajuste_contratual     IS 'D) = Valor de Ajuste Contratual';
COMMENT ON COLUMN controle_conservacao.medicoes.valor_processo              IS 'E) = (A+B+C+D) -> Valor Total do processo a ser encaminhado para o financeiro';
COMMENT ON COLUMN controle_conservacao.medicoes.descricao_glosa             IS 'Descrição do valor informado em (C)';
COMMENT ON COLUMN controle_conservacao.medicoes.descricao_ajuste_contratual IS 'Descrição do Valor informado em (D)';
COMMENT ON COLUMN controle_conservacao.medicoes.obs_responsavel             IS 'Campo livre para informações adicionais por parte da empresa.';
COMMENT ON COLUMN controle_conservacao.medicoes.obs_fiscal                  IS 'Campo livre para informações adicionais por parte do fiscal.';
COMMENT ON COLUMN controle_conservacao.medicoes.id_fora_padrao              IS 'Id da tabela: [medicoes_fora_padrao] com informações do calendario a ser seguido para apresentação da medição.';
COMMENT ON COLUMN controle_conservacao.medicoes.id_periodo                  IS 'Id do Periodo do Medição. Ver Tabela: der_ce_medicao.periodos_medicoes_obras';
COMMENT ON COLUMN controle_conservacao.medicoes.id_periodo_vigencia         IS 'Id do periodo de vigencia ao qual a medição está Associado (Somente Contr. Natureza Continua)';
COMMENT ON COLUMN controle_conservacao.medicoes.id_status_fisico            IS 'Id do Status Fisico da Medição. Ver tabela: status_medicao_fisico';
COMMENT ON COLUMN controle_conservacao.medicoes.id_status_financeiro        IS 'Id do Status Financeiro da Medição. Ver tabela: status_medicao_financeiro';
COMMENT ON COLUMN controle_conservacao.medicoes.id_pre_liquidacao           IS 'Integração com a rotina de Pré Liquidação';
COMMENT ON COLUMN controle_conservacao.medicoes.id_despacho                 IS 'Integração com a rotina de controle de Despacho';
COMMENT ON COLUMN controle_conservacao.medicoes.id_despesa                  IS 'Integração com a rotina de Controle de Despesa do Módulo Financeiro.';
COMMENT ON COLUMN controle_conservacao.medicoes.id_despesa_contrato_tipo1   IS 'Integra medicao com Despesa de contrato tipo=[Reajuste Fora do Padrão].';
COMMENT ON COLUMN controle_conservacao.medicoes.id_despesa_contrato_tipo2   IS 'Integra medicao com Despesa de contrato tipo=[Diferença Reajuste da Medição].';
COMMENT ON COLUMN controle_conservacao.medicoes.id_despesa_contrato_tipo3   IS 'Integra medicao com Despesa de contrato tipo=[Correção Motetaria da Medição].';
COMMENT ON COLUMN controle_conservacao.medicoes.doc_digitais_conferido      IS 'TRUE Indica que os documentos digitais Id do periodo de vigencia ao qual a medição está Associado (Somente Contr. Natureza Continua)';
COMMENT ON COLUMN controle_conservacao.medicoes.nr_recibo                   IS 'Gerado automaticamente na Trigger Before UPDATE quando da apresentação da Medição';

CREATE TABLE controle_conservacao.medicoes_ajustes (
    id_medicao        integer       NOT NULL,
    id                integer       NOT NULL DEFAULT 
                      nextval(('controle_conservacao.sq_medicoes_ajustes')),
    autorizado_por    varchar(100)  NOT NULL,
    motivo            varchar(255)  NOT NULL,
    data_ajuste       date          NOT NULL DEFAULT now(),
    valor_anterior    numeric(16,2) NOT NULL DEFAULT 0,
    valor_ajuste      numeric(16,2) NOT NULL DEFAULT 0,
    novo_valor        numeric(16,2) NOT NULL DEFAULT 0
) WITHOUT OIDS;

COMMENT ON  TABLE controle_conservacao.medicoes_ajustes  IS 'Armazena informações de ajuste nas medições de conservação rodoviaria. (Legado)';

CREATE TABLE controle_conservacao.medicoes_historicos (
    id_medicao        integer      NOT NULL,
    id                integer      NOT NULL DEFAULT 
                      nextval('controle_conservacao.sq_medicoes_historicos'),
    data_hora         timestamp    WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    id_tipo_historico integer      NOT NULL,
    matricula         varchar(14)  NOT NULL,
    observacao        varchar(255) NOT NULL
) WITHOUT OIDS;

COMMENT ON  TABLE controle_conservacao.medicoes_ajustes  IS 'Armazena informações dos historicos das transações realizada com as medições de contratos de conserva.';

CREATE TABLE controle_conservacao.medicoes_fora_padrao (
	id_contrato             INTEGER       NOT NULL,
	id_medicao              INTEGER       NOT NULL,
	id                      INTEGER       NOT NULL DEFAULT 
	                                      nextval('controle_conservacao.sq_medicoes_fora_padrao'),
	id_periodo_referencia   INTEGER       NOT NULL,
	id_periodo_apresentacao INTEGER       NOT NULL,
	nr_medicao              INTEGER       NOT NULL,
	tipo_medicao            INTEGER       NOT NULL,
	autorizado_por          VARCHAR(100)  NOT NULL,
	motivo                  VARCHAR(255)  NOT NULL,
	documento               VARCHAR(50),
	data_inicio_medicao     DATE          NOT NULL,
	data_fim_medicao        DATE          NOT NULL,
	qtd_dias_medido         INTEGER       NOT NULL,
	data_hora_registro      TIMESTAMP     WITHOUT TIME ZONE DEFAULT now(),
	apresentar_ate          TIMESTAMP     WITHOUT TIME ZONE NOT NULL,
	validar_ate             TIMESTAMP     WITHOUT TIME ZONE NOT NULL,
	valor_minimo            NUMERIC(16,2) DEFAULT 0
) WITHOUT OIDS;
     
COMMENT ON  TABLE controle_conservacao.medicoes_fora_padrao IS 'Armazena informações sobre medições que serão apresentadas fora do padrão do periodo vigente.';
COMMENT ON COLUMN controle_conservacao.medicoes_fora_padrao.id_contrato             IS 'Id do contrato de conserva ao qual o dados deste registro devem substituir a do periodo padrão.';
COMMENT ON COLUMN controle_conservacao.medicoes_fora_padrao.id_medicao              IS 'Id da medição ao qual o dados deste registro devem substituir a do periodo padrão.';
COMMENT ON COLUMN controle_conservacao.medicoes_fora_padrao.id_periodo_referencia   IS 'Periodo em que a medição deveria ter sido apresentada';
COMMENT ON COLUMN controle_conservacao.medicoes_fora_padrao.id_periodo_apresentacao IS 'Periodo em que a medição foi realmente apresentada';
COMMENT ON COLUMN controle_conservacao.medicoes_fora_padrao.nr_medicao              IS 'Numero da medição que esta sendo utilizada para este dados.';
COMMENT ON COLUMN controle_conservacao.medicoes_fora_padrao.tipo_medicao            IS '0. Medição ZERO - 1. Medição com Valor';
COMMENT ON COLUMN controle_conservacao.medicoes_fora_padrao.autorizado_por          IS 'Nome do Gestor que autorizou a abertura da medição fora do periodo';
COMMENT ON COLUMN controle_conservacao.medicoes_fora_padrao.motivo                  IS 'Motivo pelo qual a medição está sendo fora do periodo';
COMMENT ON COLUMN controle_conservacao.medicoes_fora_padrao.documento               IS 'Opcional (CI, Protocolo...)';
COMMENT ON COLUMN controle_conservacao.medicoes_fora_padrao.data_inicio_medicao     IS 'Data de Inicio do período refente a medição do registro.';
COMMENT ON COLUMN controle_conservacao.medicoes_fora_padrao.data_fim_medicao        IS 'Data de Término do período referente a medição do registro.';
COMMENT ON COLUMN controle_conservacao.medicoes_fora_padrao.qtd_dias_medido         IS '= (data_fim_medicao - data_inicio_medicao) ';
COMMENT ON COLUMN controle_conservacao.medicoes_fora_padrao.data_hora_registro      IS 'Gerado automaticamente no momento da inclusão.';
COMMENT ON COLUMN controle_conservacao.medicoes_fora_padrao.apresentar_ate          IS 'Data e hora limite para apresentação da medição do tipo 1.';
COMMENT ON COLUMN controle_conservacao.medicoes_fora_padrao.validar_ate             IS 'Data e hora limite para validação da medição do tipo 1.';
COMMENT ON COLUMN controle_conservacao.medicoes_fora_padrao.valor_minimo            IS 'Valor minimo a ser apresentado na medição. Se Zero liberado para qualquer valor';

CREATE TABLE controle_conservacao.contratos_fiscais (
  id             INTEGER    NOT NULL DEFAULT 
                 nextval('controle_conservacao.sq_contratos_fiscais'),
  id_contrato    INTEGER    NOT NULL,
  id_tipo_fiscal INTEGER    NOT NULL,
  id_fiscal      VARCHAR(8) NOT NULL,
  observacao     VARCHAR(255)
) WITHOUT OIDS;

COMMENT ON  TABLE controle_conservacao.contratos_fiscais IS 'Armazena a lista de fiscais atuais do contrato de conserva.';
COMMENT ON COLUMN controle_conservacao.contratos_fiscais.id_contrato    IS 'Id do Contrato de conserva ao qual o fiscal faz parte da Comissão.';
COMMENT ON COLUMN controle_conservacao.contratos_fiscais.id_tipo_fiscal IS 'Id do tipo de fiscal. ver tabela: der_ce_obra.tipo_fiscal.';
COMMENT ON COLUMN controle_conservacao.contratos_fiscais.id_fiscal      IS 'Matricula do funcionario da SOP que fiscaliza a conserva.';
COMMENT ON COLUMN controle_conservacao.contratos_fiscais.observacao     IS 'Campo Livre para informações adicionais.';

CREATE TABLE controle_conservacao.medicoes_fiscais (
  id             INTEGER    NOT NULL DEFAULT 
                 nextval('controle_conservacao.sq_medicoes_fiscais'),
  id_contrato    INTEGER    NOT NULL,
  id_medicao     INTEGER    NOT NULL,
  id_tipo_fiscal INTEGER    NOT NULL,
  id_fiscal      VARCHAR(8) NOT NULL,
  observacao     VARCHAR(255)
) WITHOUT OIDS;

COMMENT ON  TABLE controle_conservacao.medicoes_fiscais IS 'Armazena a lista de fiscais que atuaram em cada medição da conserva.';
COMMENT ON COLUMN controle_conservacao.contratos_fiscais.id_contrato   IS 'Id do Contrato de conserva ao qual o fiscal faz parte da Comissão.';
COMMENT ON COLUMN controle_conservacao.medicoes_fiscais.id_medicao     IS 'Id da Medição de conserva ao qual o fiscal faz parte da Comissão.';
COMMENT ON COLUMN controle_conservacao.medicoes_fiscais.id_tipo_fiscal IS 'Id do tipo de fiscal. ver tabela: der_ce_obra.tipo_fiscal.';
COMMENT ON COLUMN controle_conservacao.medicoes_fiscais.id_fiscal      IS 'Matricula do funcionario da SOP que fiscaliza a conserva.';
COMMENT ON COLUMN controle_conservacao.medicoes_fiscais.observacao     IS 'Campo Livre para informações adicionais.';

-- =============================================================================
-- P R I M A R Y   K E Y ´ s  
-- =============================================================================
ALTER TABLE ONLY controle_conservacao.status_medicao_fisico     ADD CONSTRAINT pk_status_medicao_fisico     PRIMARY KEY (id);
ALTER TABLE ONLY controle_conservacao.status_medicao_financeiro ADD CONSTRAINT pk_status_medicao_financeiro PRIMARY KEY (id);
ALTER TABLE ONLY controle_conservacao.tipo_historico_medicoes   ADD CONSTRAINT pk_tipo_historico_medicoes   PRIMARY KEY (id);
ALTER TABLE ONLY controle_conservacao.medicoes                  ADD CONSTRAINT pk_medicoes                  PRIMARY KEY (id);
ALTER TABLE ONLY controle_conservacao.medicoes_ajustes          ADD CONSTRAINT pk_medicoes_ajustes          PRIMARY KEY (id);
ALTER TABLE ONLY controle_conservacao.medicoes_historicos       ADD CONSTRAINT pk_medicoes_historicos       PRIMARY KEY (id);
ALTER TABLE ONLY controle_conservacao.medicoes_fora_padrao      ADD CONSTRAINT pk_medicoes_fora_padrao      PRIMARY KEY (id);
ALTER TABLE ONLY controle_conservacao.medicoes_fiscais          ADD CONSTRAINT pk_medicoes_fiscais          PRIMARY KEY (id);
ALTER TABLE ONLY controle_conservacao.contratos_fiscais         ADD CONSTRAINT pk_contratos_fiscais         PRIMARY KEY (id);

-- =============================================================================
-- C R I A Ç Ã O   D A S   A L T E R N A T E   K E Y
-- =============================================================================
CREATE UNIQUE INDEX ak_medicoes_nr_protocolo 
    ON controle_conservacao.medicoes
 USING btree (nr_protocolo);

-- =============================================================================
-- F O R E I G N   K E Y ´ s   d o   p a c o t e   CONSERVACAO
-- =============================================================================
-- Foreing Key´s da tabela 'medicoes'
-- -----------------------------------------------------------------------------
ALTER TABLE ONLY controle_conservacao.medicoes
  ADD CONSTRAINT fk_contratos                   FOREIGN KEY (id_contrato)
      REFERENCES der_ce_contrato.contratos(id);

ALTER TABLE ONLY controle_conservacao.medicoes
  ADD CONSTRAINT fk_contratos_periodos_vigencia FOREIGN KEY (id_periodo_vigencia)
      REFERENCES der_ce_contrato.contratos_periodos_vigencia(id);

ALTER TABLE ONLY controle_conservacao.medicoes
  ADD CONSTRAINT fk_medicoes_fora_padrao       FOREIGN KEY (id_fora_padrao)
      REFERENCES controle_conservacao.medicoes_fora_padrao(id);
     
ALTER TABLE ONLY controle_conservacao.medicoes
  ADD CONSTRAINT fk_status_medicao_fisico       FOREIGN KEY (id_status_fisico)
      REFERENCES controle_conservacao.status_medicao_fisico(id);

ALTER TABLE ONLY controle_conservacao.medicoes
  ADD CONSTRAINT fk_status_medicao_financeiro   FOREIGN KEY (id_status_financeiro)
      REFERENCES controle_conservacao.status_medicao_financeiro(id);

ALTER TABLE ONLY controle_conservacao.medicoes
  ADD CONSTRAINT fk_periodos_medicoes_obras     FOREIGN KEY (id_periodo)
  REFERENCES     der_ce_medicao.periodos_medicoes_obras(id);

ALTER TABLE ONLY controle_conservacao.medicoes
  ADD CONSTRAINT fk_despacho                    FOREIGN KEY (id_despacho)
      REFERENCES controle_despachos.despachos(id);

ALTER TABLE ONLY controle_conservacao.medicoes
  ADD CONSTRAINT fk_despesas                    FOREIGN KEY (id_despesa)
      REFERENCES der_ce_financeiro_despesa.despesas(id);

ALTER TABLE ONLY controle_conservacao.medicoes
  ADD CONSTRAINT fk_pre_liquidacao              FOREIGN KEY (id_pre_liquidacao)
      REFERENCES der_ce_financeiro_imposto.pre_liquidacoes(id);

ALTER TABLE controle_conservacao.medicoes ADD CONSTRAINT fk_despesas_contrato_x_medicoes_tipo1 
FOREIGN KEY (id_despesa_contrato_tipo1)                     REFERENCES der_ce_contrato_despesas.despesas_contrato_x_medicoes(id)
  ON DELETE SET NULL ON UPDATE NO ACTION                    DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE controle_conservacao.medicoes ADD CONSTRAINT fk_despesas_contrato_x_medicoes_tipo2 
FOREIGN KEY (id_despesa_contrato_tipo2)                     REFERENCES der_ce_contrato_despesas.despesas_contrato_x_medicoes(id)
  ON DELETE SET NULL ON UPDATE NO ACTION                    DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE controle_conservacao.medicoes ADD CONSTRAINT fk_despesas_contrato_x_medicoes_tipo3 
FOREIGN KEY (id_despesa_contrato_tipo3)                     REFERENCES der_ce_contrato_despesas.despesas_contrato_x_medicoes(id)
  ON DELETE SET NULL ON UPDATE NO ACTION                    DEFERRABLE INITIALLY DEFERRED;

COMMENT ON CONSTRAINT fk_despesas                           ON controle_conservacao.medicoes IS 'Integração com a rotina de Controle de Despesa do Módulo Financeiro.';
COMMENT ON CONSTRAINT fk_despesas_contrato_x_medicoes_tipo1 ON controle_conservacao.medicoes IS 'Integra medicao com Despesa de contrato tipo=[Reajuste Fora do Padrão].';
COMMENT ON CONSTRAINT fk_despesas_contrato_x_medicoes_tipo2 ON controle_conservacao.medicoes IS 'Integra medicao com Despesa de contrato tipo=[Diferença Reajuste da Medição].';
COMMENT ON CONSTRAINT fk_despesas_contrato_x_medicoes_tipo3 ON controle_conservacao.medicoes IS 'Integra medicao com Despesa de contrato tipo=[Correção Motetaria da Medição].';

-- Foreing Key´s da tabela 'medicoes_ajustes'
-- -----------------------------------------------------------------------------
ALTER TABLE ONLY controle_conservacao.medicoes_ajustes
  ADD CONSTRAINT fk_medicoes       FOREIGN KEY (id_medicao)
      REFERENCES controle_conservacao.medicoes(id);

-- Foreing Key´s da tabela 'medicoes_historicos'
-- -----------------------------------------------------------------------------
ALTER TABLE ONLY controle_conservacao.medicoes_historicos
  ADD CONSTRAINT fk_medicoes       FOREIGN KEY (id_medicao)
      REFERENCES controle_conservacao.medicoes(id);
     
ALTER TABLE ONLY controle_conservacao.medicoes_historicos
  ADD CONSTRAINT fk_tipo_historico FOREIGN KEY (id_tipo_historico)
      REFERENCES controle_conservacao.tipo_historico_medicoes(id);

-- Foreing Key´s da tabela 'medicoes_fora_padrao'
-- -----------------------------------------------------------------------------
ALTER TABLE ONLY controle_conservacao.medicoes_fora_padrao
  ADD CONSTRAINT fk_contratos             FOREIGN KEY (id_contrato)
      REFERENCES der_ce_contrato.contratos(id);
     
ALTER TABLE ONLY controle_conservacao.medicoes_fora_padrao
  ADD CONSTRAINT fk_medicoes              FOREIGN KEY (id_medicao)
      REFERENCES controle_conservacao.medicoes(id);
     
ALTER TABLE ONLY controle_conservacao.medicoes_fora_padrao
  ADD CONSTRAINT fk_periodos_referencia   FOREIGN KEY (id_periodo_referencia)
      REFERENCES der_ce_medicao.periodos_medicoes_obras(id);
     
ALTER TABLE ONLY controle_conservacao.medicoes_fora_padrao
  ADD CONSTRAINT fk_periodos_apresentacao FOREIGN KEY (id_periodo_referencia)
      REFERENCES der_ce_medicao.periodos_medicoes_obras(id);
          
-- Foreing Key´s da tabela 'contratos_fiscais'
-- -----------------------------------------------------------------------------
ALTER TABLE ONLY controle_conservacao.contratos_fiscais
  ADD CONSTRAINT fk_contratos    FOREIGN KEY (id_contrato)
      REFERENCES der_ce_contrato.contratos(id);

ALTER TABLE ONLY controle_conservacao.contratos_fiscais
  ADD CONSTRAINT fk_fiscal       FOREIGN KEY (id_fiscal)
      REFERENCES der_ce_coorporativo.funcionarios(matricula);

ALTER TABLE ONLY controle_conservacao.contratos_fiscais
  ADD CONSTRAINT fk_tipo_fiscal  FOREIGN KEY (id_tipo_fiscal)
      REFERENCES der_ce_obra.tipo_fiscal(id);

-- Foreing Key´s da tabela 'medicoes_fiscais'
-- -----------------------------------------------------------------------------
ALTER TABLE ONLY controle_conservacao.medicoes_fiscais
  ADD CONSTRAINT fk_contratos    FOREIGN KEY (id_contrato)
      REFERENCES der_ce_contrato.contratos(id);
     
ALTER TABLE ONLY controle_conservacao.medicoes_fiscais
  ADD CONSTRAINT fk_medicoes     FOREIGN KEY (id_medicao)
      REFERENCES controle_conservacao.medicoes(id);

ALTER TABLE ONLY controle_conservacao.medicoes_fiscais
  ADD CONSTRAINT fk_fiscal       FOREIGN KEY (id_fiscal)
      REFERENCES der_ce_coorporativo.funcionarios(matricula);

ALTER TABLE ONLY controle_conservacao.medicoes_fiscais
  ADD CONSTRAINT fk_tipo_fiscal  FOREIGN KEY (id_tipo_fiscal)
      REFERENCES der_ce_obra.tipo_fiscal(id);

-- =============================================================================
-- INSERTS das Tabelas DICIONARIO
-- =============================================================================
-- Tabela: controle_conservacao.status_processo_medicao_conserva
-- -----------------------------------------------------------------------------
/* A N T E S
INSERT INTO controle_conservacao.status_processo_medicao_conserva (id, descricao, tipo, sigla, cor_status, icone_status) VALUES (1,'Aguardando Análise de Documentos','AGUARDANDO_ANALISE',    'AAD','#000000','status_processo_medicao_conserva_1.png');
INSERT INTO controle_conservacao.status_processo_medicao_conserva (id, descricao, tipo, sigla, cor_status, icone_status) VALUES (2,'Aguardando Resolver Pendencias',  'AGUARDANDO_PENDENCIAS', 'ARP','#000000','status_processo_medicao_conserva_2.png');
INSERT INTO controle_conservacao.status_processo_medicao_conserva (id, descricao, tipo, sigla, cor_status, icone_status) VALUES (3,'Aguardando Empenho',              'AGUARDANDO_EMPENHO',    'AEM','#000000','status_processo_medicao_conserva_3.png');
INSERT INTO controle_conservacao.status_processo_medicao_conserva (id, descricao, tipo, sigla, cor_status, icone_status) VALUES (4,'Parcialmente Empenhado',          'PARCIALMENTE_EMPENHADO','PEM','#000000','status_processo_medicao_conserva_4.png');
INSERT INTO controle_conservacao.status_processo_medicao_conserva (id, descricao, tipo, sigla, cor_status, icone_status) VALUES (5,'Aguardando Pagamento',            'AGUARDANDO_PAGAMENTO',  'APG','#000000','status_processo_medicao_conserva_5.png');
INSERT INTO controle_conservacao.status_processo_medicao_conserva (id, descricao, tipo, sigla, cor_status, icone_status) VALUES (6,'Parcialmente Pago',               'PARCIALMENTE_PAGO',     'PPG','#000000','status_processo_medicao_conserva_6.png');
INSERT INTO controle_conservacao.status_processo_medicao_conserva (id, descricao, tipo, sigla, cor_status, icone_status) VALUES (7,'Pago',                            'PAGO',                  'PAG','#000000','status_processo_medicao_conserva_7.png');
INSERT INTO controle_conservacao.status_processo_medicao_conserva (id, descricao, tipo, sigla, cor_status, icone_status) VALUES (8,'Cancelado',                       'CANCELADO',             'CAN','#000000','status_processo_medicao_conserva_8.png');
*/
     
INSERT INTO controle_conservacao.status_medicao_fisico (id, cor, sigla, descricao, especificacao) VALUES 
(1 ,'#f50a15' ,'ABE' ,'Aberta'                   ,'Medição que foi aberta mas ainda não foi apresentada.'),
(2 ,'#f0af09' ,'AVA' ,'Aguardando Validação'     ,'Medição apresentada mas ainda não validada pelo fiscal.'),
(3 ,'#f0af09' ,'AAS' ,'Aguardando Assinaturas'   ,'Medição Validada pelo fiscal mas ainda com assinaturas pendentes.'),
(4 ,'#f50ced' ,'ACO' ,'Aguardando Conferencia'   ,'Medição com assinaturas concluidas mas ainda não confererida pela GEMED.'),
(5 ,'#f50ced' ,'APT' ,'Aguardando Protocolo'     ,'Medição com a documentação conferida e liberada p/ protocolar mas ainda não protocolada.'),
(6 ,'#a40cf0' ,'AAD' ,'Aguardando Administrativo','Medição protocolada sob analise administrativa mas ainda não encmainhada para o financeiro.'),
(7 ,'#00FF00' ,'FEC' ,'Fechada'                  ,'Medição Encaminhada para Financeiro e Fechada, para abertura de uma próxima.');

INSERT INTO controle_conservacao.status_medicao_financeiro (id, cor, sigla, descricao, especificacao) VALUES 
(0 ,'#f0af09' ,'ANP' ,'Ainda Não Encaminhado'         ,'Medição com status fisico ainda não encaminhada para o financeiro.'),
(1 ,'#f0af09' ,'AAD' ,'Aguardando classificacao'      ,'Medição de Valor encaminhada para financeiro ainda não classificada.'),
(2 ,'#f50a15' ,'ARP' ,'Aguardando Pendencias'         ,'Medição foi classificada mais esta aguardando resolver pendencias.'),
(3 ,'#f50ced' ,'AEM' ,'Aguardando Empenho'            ,'Medição foi liberada para empenhar, mas ainda não foi empenhada.'),
(4 ,'#a40cf0' ,'PEM' ,'Parcialmente Empenhado'        ,'Medição possui registro(s) de empenho(s) , mas, o(s) valor(es) são inferiores ao valor total.'),
(5 ,'#f5a608' ,'APG' ,'Aguardando Pagamento'          ,'Medição foi totalmente empenhada, mas, ainda não houve registro de pagamento.'),
(6 ,'#f5a608' ,'PPG' ,'Parcialmente Pago'             ,'Medição possui registro(s) de pagamento(s) , mas, o(s) valor(es) são inferiores ao valor total.'),
(7 ,'#00FF00' ,'PAG' ,'Pago'                          ,'Medição foi totalmente paga e não existe nenhuma divida relacionada.'),
(9 ,'#08fafa' ,'MZE' ,'Medição Zero'                  ,'Medição foi apresentada ou Gerada como ZERO. Sem movimentação financeira');

INSERT INTO controle_conservacao.tipo_historico_medicoes (id, descricao) VALUES 
( 1 ,'Medicao Padrão Aberta'),
( 2 ,'Medicao Fora Padrão Aberta'),
( 3 ,'Medicao Apresentada com Valor'),
( 4 ,'Medicao ZERO Apresentada'),
( 5 ,'Medicao Zerada Pelo SISTEMA'),
( 6 ,'Medicao Validada Pelo Fiscal'),
( 7 ,'Medicao Rejeitada Pelo Fiscal'),
( 8 ,'Assinaturas Documentos da Medição Finalizada'),
( 9 ,'Docs. digitais conferidos foram Recusados'),
(10 ,'Medição Reaberta p/ Contratada'),
(11 ,'Conferencia Docs. Finalizada'),
(12 ,'Medicao Liberada p/ Peotocolar'),
(13 ,'Protocolo da Medição Registrada'),
(14 ,'Protocolo Encaminhado para Financeiro'),
(15 ,'Medição Fechada'),
(16 ,'Data de Apresentação Prorrogada'),
(17 ,'Medição Reaberta p/ Fiscal'),
(18 ,'Data de Validação Prorrogada'), 
(19 ,'Medição ZERO Fora do Padrão Apresentada'),
(24,'Intervenção solicitada por Gestor'),
(25,'Correção de dados da medição'),
(27,'Valores da Medição Ajustados'),
(28,'Medição Cancelada'),
(29,'Medição Importada da base Leg'),
(30,'Ajuste de Integraçao com Financeiro'),

(40,'Empenhada 100%'),
(41,'Empenhada Parcialmente'),
(42,'Empenhado Restante'),
(43,'Paga 100%'),
(44,'Paga Parcialmente'),
(45,'Paga Restante');

-- =============================================================================
-- FIM: Tabelas Schema CONSERVACAO
-- =============================================================================

-- =============================================================================
--
-- FIM: C R I A Ç Â O   d a s   T A B E L A S
--
-- =============================================================================

CREATE TABLE controle_conservacao.situacao_abertura_medicao (
    id            INTEGER      NOT NULL,
    cor           VARCHAR(8)   NOT NULL,
    sigla         VARCHAR(3)   NOT NULL,
    descricao     varchar(50)  NOT NULL,
    especificacao varchar(255) NOT NULL
) WITHOUT OIDS;

ALTER TABLE ONLY controle_conservacao.situacao_abertura_medicao  ADD CONSTRAINT pk_situacao_abertura_medicao  PRIMARY KEY (id);


INSERT INTO controle_conservacao.situacao_abertura_medicao (id, cor, sigla, descricao, especificacao) VALUES 
(1 ,'#0000FF' ,'JFA' ,'Ja Foi Aberta'    ,'Quando a Medição a ser aberta já foi aberta no periodo Ativo.'),
(2 ,'#00FF00' ,'APD' ,'Abrir Padrão'     ,'Quando a Medição é referente ao periodo Ativo.'),
(3 ,'#D98F07' ,'AFP' ,'Abrir Fora Padrão','Quando a Medição é referente a um periodo diferente do Ativo.'),
(4 ,'#FF0000' ,'IMA' ,'Impossivel Abrir' ,'Quando existir algum impedimento para abertura da Medição.');

