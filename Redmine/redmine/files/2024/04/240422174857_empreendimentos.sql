CREATE OR REPLACE FUNCTION public.criacao_tabelas_empreendimento (
)
    RETURNS pg_catalog.void AS
$body$
begin

    RAISE NOTICE '=================================================';
    RAISE NOTICE 'I. SCHEMA & TABLES';
    RAISE NOTICE '=================================================';

    RAISE NOTICE '=================================================';
    RAISE NOTICE 'I.I. RESET';
    RAISE NOTICE '=================================================';

    RAISE NOTICE '	empreendimentos.endereco';
    DROP TABLE IF EXISTS empreendimentos.endereco;

    RAISE NOTICE '	empreendimentos.empreendimento_edificacao';
    DROP TABLE IF EXISTS empreendimentos.empreendimento_edificacao;

    RAISE NOTICE '	empreendimentos.porte';
    DROP TABLE IF EXISTS empreendimentos.porte;

    RAISE NOTICE '	empreendimentos.demanda_x_empreendimento';
    DROP TABLE IF EXISTS empreendimentos.demanda_x_empreendimento;

    RAISE NOTICE '	empreendimentos.demanda';
    DROP TABLE IF EXISTS empreendimentos.demanda;

    RAISE NOTICE '	empreendimentos.item';
    DROP TABLE IF EXISTS empreendimentos.item;

    RAISE NOTICE '	empreendimentos.status_item';
    DROP TABLE IF EXISTS empreendimentos.status_item;

    RAISE NOTICE '	empreendimentos.classificacao_item';
    DROP TABLE IF EXISTS empreendimentos.classificacao_item;

    RAISE NOTICE '	empreendimentos.tipo_item';
    DROP TABLE IF EXISTS empreendimentos.tipo_item;

    RAISE NOTICE '	empreendimentos.empreendimento';
    DROP TABLE IF EXISTS empreendimentos.empreendimento;

    RAISE NOTICE '	empreendimentos.origem';
    DROP TABLE IF EXISTS empreendimentos.origem;

    RAISE NOTICE '	empreendimentos';
    drop schema if exists empreendimentos;

    RAISE NOTICE '=================================================';
    RAISE NOTICE 'I.II. CREATE SCHEMA & TABLES';
    RAISE NOTICE '=================================================';

    raise notice '	empreendimentos';
    create schema empreendimentos;

    RAISE NOTICE '	empreendimentos.origem';
    CREATE TABLE IF NOT EXISTS empreendimentos.origem (
        id smallint NOT NULL,
        descricao text NULL,
        sigla varchar(3) null,
        CONSTRAINT pk_origem PRIMARY KEY (id)
    );

    RAISE NOTICE '	empreendimentos.empreendimento';
    CREATE TABLE IF NOT EXISTS empreendimentos.empreendimento (
        id serial NOT NULL,
        codigo text NULL,
        objeto text null,
        data_cadastro date,
        id_origem smallint not null,
        CONSTRAINT pk_empreendimento PRIMARY KEY (id),
        CONSTRAINT fk_origem FOREIGN KEY (id_origem) REFERENCES empreendimentos.origem(id)
    );

    RAISE NOTICE '	empreendimentos.tipo_item';
    CREATE TABLE IF NOT EXISTS empreendimentos.tipo_item (
        id smallint NOT NULL,
        descricao text NULL,
        sigla varchar(3) null,
        CONSTRAINT pk_tipo_item PRIMARY KEY (id)
    );

    RAISE NOTICE '	empreendimentos.classificacao_item';
    CREATE TABLE IF NOT EXISTS empreendimentos.classificacao_item (
        id smallint NOT NULL,
        descricao text NULL,
        sigla varchar(3) null,
        CONSTRAINT pk_classificacao_item PRIMARY KEY (id)
    );

    RAISE NOTICE '	empreendimentos.status_item';
    CREATE TABLE IF NOT EXISTS empreendimentos.status_item (
        id smallint NOT NULL,
        descricao text NULL,
        sigla varchar(3) null,
        CONSTRAINT pk_status_item PRIMARY KEY (id)
    );

    RAISE NOTICE '	empreendimentos.item';
    CREATE TABLE IF NOT EXISTS empreendimentos.item (
        id serial NOT NULL,
        codigo text not NULL,
        descricao text null,
        data_cadastro date not null,
        nr_protocolo text,
        desincorporavel bool not null,
        data_desincorporacao date null,
        licenciavel bool not null,
        id_empreendimento integer not null,
        id_classificacao smallint not null,
        id_tipo smallint not null,
        id_status smallint not null,
        CONSTRAINT pk_item PRIMARY KEY (id),
        CONSTRAINT fk_empreendimento FOREIGN KEY (id_empreendimento) REFERENCES empreendimentos.empreendimento(id),
        CONSTRAINT fk_classificacao FOREIGN KEY (id_classificacao) REFERENCES empreendimentos.classificacao_item(id),
        CONSTRAINT fk_tipo FOREIGN KEY (id_tipo) REFERENCES empreendimentos.tipo_item(id),
        CONSTRAINT fk_status FOREIGN KEY (id_status) REFERENCES empreendimentos.status_item(id)
    );

    RAISE NOTICE '	empreendimentos.demanda';
    CREATE TABLE IF NOT EXISTS empreendimentos.demanda (
        id serial NOT NULL,
        codigo text not NULL,
        descricao text null,
        data_cadastro date not null,
        is_pacote bool not null,
        qtd_empreendimentos smallint null,
        CONSTRAINT pk_demanda PRIMARY KEY (id)
    );

    RAISE NOTICE '	empreendimentos.demanda_x_empreendimento';
    CREATE TABLE IF NOT EXISTS empreendimentos.demanda_x_empreendimento (
        id_demanda integer NOT NULL unique,
        id_empreendimento integer not NULL unique,
        constraint pk_demanda_x_empreendimento primary key (id_demanda, id_empreendimento),
        CONSTRAINT fk_demanda FOREIGN KEY (id_demanda) REFERENCES empreendimentos.demanda(id),
        CONSTRAINT fk_empreendimento FOREIGN KEY (id_empreendimento) REFERENCES empreendimentos.empreendimento(id)
    );

    RAISE NOTICE '	empreendimentos.porte';
    CREATE TABLE IF NOT EXISTS empreendimentos.porte (
        id smallint NOT NULL,
        descricao text NULL,
        sigla varchar(3) null,
        CONSTRAINT pk_porte PRIMARY KEY (id)
    );

    RAISE NOTICE '	empreendimentos.empreendimento_edificacao';
    CREATE TABLE IF NOT EXISTS empreendimentos.empreendimento_edificacao (
        id serial NOT NULL,
        id_empreendimento integer not NULL,
        id_classificacao text not NULL,
        id_porte smallint not NULL,
        CONSTRAINT pk_empreendimento_edificacao PRIMARY KEY (id),
        CONSTRAINT fk_empreendimento FOREIGN KEY (id_empreendimento) REFERENCES empreendimentos.empreendimento(id),
        CONSTRAINT fk_classificacao FOREIGN KEY (id_classificacao) REFERENCES dae_ce_obra.tipo_obra(id),
        CONSTRAINT fk_porte FOREIGN KEY (id_porte) REFERENCES empreendimentos.porte(id)

    );

    RAISE NOTICE '	empreendimentos.endereco';
    CREATE TABLE IF NOT EXISTS empreendimentos.endereco (
        id serial NOT NULL,
        latitude float NOT NULL,
        longitude float NOT NULL,
        cep varchar(8) null,
        logradouro text null,
        complemento text null,
        bairro text null,
        localidade text null,
        numero text null,
        uf varchar(2) null,
        id_empreendimento_edificacao integer not null,
        CONSTRAINT pk_endereco PRIMARY KEY (id),
        constraint fk_empreendimento_edificacao foreign key (id_empreendimento_edificacao) references empreendimentos.empreendimento_edificacao(id)
    );

    RAISE NOTICE '=================================================';
    RAISE NOTICE 'I.III. INSERTS';
    RAISE NOTICE '=================================================';

    RAISE NOTICE '	empreendimentos.origem';
    INSERT INTO empreendimentos.origem (id, descricao, sigla) VALUES
    (1,'Edificações', 'EDF'),
    (2,'Rodovias', 'ROD'),
    (3,'Aeroportos', 'AER');

    RAISE NOTICE '	empreendimentos.tipo_item';
    INSERT INTO empreendimentos.tipo_item (id, descricao, sigla) VALUES
    (1,'Obra', 'OBR'),
    (2,'Manutenção', 'MAN'),
    (3,'Aquisição', 'AQI');

    RAISE NOTICE '	empreendimentos.classificacao_item';
    INSERT INTO empreendimentos.classificacao_item (id, descricao, sigla) VALUES
    (1,'Obra', 'OBR'),
    (2,'Ampliação', 'AMP'),
    (3,'Ampliação/Reforma', 'ARF'),
    (4,'Ampliação/Restauração', 'ART'),
    (5,'Implantação', 'IMP'),
    (6,'Reforma', 'REF'),
    (7,'Restauração', 'RES'),
    (8,'Não definido', 'NDF');

    RAISE NOTICE '	empreendimentos.status_item';
    INSERT INTO empreendimentos.status_item (id, descricao, sigla) VALUES
    (1,'Aguardando Projeto', 'AGP'),
    (2,'Aguardando Licenciamento', 'AGL'),
    (3,'Aguardando Licitação', 'ALI'),
    (4,'Aguardando Contrato', 'ACT'),
    (5,'Finalizado', 'FIN');

    RAISE NOTICE '=================================================';
    RAISE NOTICE 'II. DOC_DIGITAL';
    RAISE NOTICE '=================================================';

    RAISE NOTICE '=================================================';
    RAISE NOTICE 'II.I. RESET';
    RAISE NOTICE '=================================================';

    RAISE NOTICE '	documento_digital.tipo_documento';
    delete from documento_digital.tipo_documento td where td.id_tipo_entidade in (611, 621);

    RAISE NOTICE '	documento_digital.tipo_arquivo';
    delete from documento_digital.tipo_arquivo ta where ta.id = 24;

    RAISE NOTICE '	documento_digital.sufixo_arquivo';
    delete from documento_digital.sufixo_arquivo sa where sa.id = 5;

    RAISE NOTICE '	documento_digital.ponto_controle';
    delete from documento_digital.ponto_controle pc where pc.id_tipo_entidade in (611, 621, 631);

    RAISE NOTICE '	documento_digital.tipo_origem_arquivo';
    delete from documento_digital.tipo_origem_arquivo toa where toa.id = 8;

    RAISE NOTICE '	documento_digital.tipo_entidade';
    delete from documento_digital.tipo_entidade te where te.id in (600, 610, 611, 620, 621, 630, 631, 640);

    RAISE NOTICE '=================================================';
    RAISE NOTICE 'II.II. INSERTS';
    RAISE NOTICE '=================================================';

    RAISE NOTICE '	documento_digital.tipo_entidade';
    INSERT INTO documento_digital.tipo_entidade (id, id_tipo_entidade_pai,  pasta, descricao, observacao) VALUES
    (600,null,'EMPMNT','Empreendimento','Documentos Relativos à um Empreendimento'),
    (610,600,'EMPEDF','Empreendimento de Edificações','Documentos Relativos à um Empreendimento de Edificações'),
    (611,610,'ITMEDF','Item de Empreendimento de Edificações','Documentos Relativos à um Item (Processo) de um Empreendimento de Edificações'),
    (620,600,'EMPROD','Empreendimento de Rodovias','Documentos Relativos à um Empreendimento de Rodovias'),
    (621,620,'ITMROD','Item de Empreendimento de Rodovias','Documentos Relativos à um Item (Processo) de um Empreendimento de Rodovias'),
    (630,600,'EMPAER','Empreendimento de Aeroporto','Documentos Relativos à um Empreendimento de Aeroporto'),
    (631,630,'ITMAER','Item de Empreendimento de Aeroporto','Documentos Relativos à um Item (Processo) de um Empreendimento de Aeroporto'),
    (640,null,'DEMNDA','Demanda','Documentos Relativos à uma Demanda');

    RAISE NOTICE '	documento_digital.tipo_origem_arquivo';
    INSERT INTO documento_digital.tipo_origem_arquivo (id, cor, sigla, descricao, especificacao) values
    (8, '#000000', 'EMP', 'SOP-Empreendimentos', 'Documentos gerados pelo Sistema de Empreendimentos');

    RAISE NOTICE '	documento_digital.tipo_arquivo';
    INSERT INTO documento_digital.tipo_arquivo (id, extensao, media_type, especificacao) values
    (24, 'dwg', 'image/x-dwg', 'AutoCAD Drawing Format');

    RAISE NOTICE '	documento_digital.ponto_controle';
    INSERT INTO documento_digital.ponto_controle (id_tipo_entidade, id, requer_liberacao, id_tipo_ocorrencia_pce, id_validacao_adicional, sigla, descricao, especificacao) VALUES
    (611, 61101, True, 1, 0, 'IEEAFE', 'Item de Empreendimento de Edificações (Antes de finalizar envio)', 'Validar Documentos Digitais Relativos ao Item de Empreendimento de Edificações (Antes de finalizar envio)'),
    (621, 62101, True, 1, 0, 'IERAFE', 'Item de Empreendimento de Rodovias (Antes de finalizar envio)', 'Validar Documentos Digitais Relativos ao Item de Empreendimento de Rodovias (Antes de finalizar envio)'),
    (631, 63101, True, 1, 0, 'IEAAFE', 'Item de Empreendimento de Aeroporto (Antes de finalizar envio)', 'Validar Documentos Digitais Relativos ao Item de Empreendimento de Aeroporto (Antes de finalizar envio)');

    RAISE NOTICE '	documento_digital.sufixo_arquivo';
    INSERT INTO documento_digital.sufixo_arquivo (id, cor, referencia, descricao, especificacao) values
    (5, '#000000', 'Empreendimento', 'Projeto de Empreendimento', 'Doc. de ocorrência MÚLTIPLA. Usa um texto qualquer.');

    RAISE NOTICE '	documento_digital.tipo_documento';
    INSERT INTO documento_digital.tipo_documento (id_tipo_entidade, id, id_tipo_versao, id_tipo_origem, requer_assinatura, unico_por_entidade, descricao, nome_arquivo, especificacao, id_sufixo_arquivo, id_tipo_arquivo) VALUES
    (611, 61101, 0, 8, false, true, 'Memorial Descritivo', 'MemorialDescritivo', '', 0, 1),
    (611, 61102, 0, 8, false, true, 'Projeto Arquitetônico', 'ProjetoArquitetonico', '', 5, 1),
    (611, 61103, 0, 8, false, true, 'Projeto Arquitetônico (Editável)', 'ProjetoArquitetonicoEditavel', '', 5, 24),
    (611, 61104, 0, 8, false, true, 'Projeto Hidrossanitário', 'ProjetoHidrossanitario', '', 5, 1),
    (611, 61105, 0, 8, false, true, 'Memorial Hidrossanitário', 'MemorialHidrossanitario', '', 0, 1),
    (611, 61106, 0, 8, false, true, 'ART/RRT', 'ArtRrt', '', 0, 1),
    (611, 61107, 0, 8, false, true, 'Viabilidade de Água/Esgoto/Energia', 'ViabiliadeAguaEsgotoEnergia', '', 0, 1),
    (611, 61108, 0, 8, false, true, 'Documento do Imóvel/Terreno', 'DocumentoImovelTerreno', '', 0, 1),
    (621, 62101, 0, 8, false, true, 'Decreto de Utilidade Pública', 'DecretoUtilidadePublica', '', 0, 1),
    (621, 62102, 0, 8, false, true, 'Projeto de Execução', 'ProjetoExecucao', '', 0, 1),
    (621, 62103, 0, 8, false, true, 'Projeto de Execução (Editável)', 'ProjetoExecucaoEditavel', '', 0, 24),
    (621, 62104, 0, 8, false, true, 'Mapa Situação', 'MapaSituacao', '', 0, 1),
    (621, 62105, 0, 8, false, true, 'Shape (.kmz)', 'Shapes', '', 0, 11),
    (621, 62106, 0, 8, false, true, 'Estudos Ambientais', 'EstudosAmbientais', '', 0, 1),
    (621, 62107, 0, 8, false, true, 'ART', 'Art', '', 0, 1),
    (621, 62108, 0, 8, false, true, 'Memorial Descritivo', 'MemorialDescritivo', '', 0, 1);

    RAISE NOTICE '======================================================================';
    RAISE NOTICE '  FINISH';
    RAISE NOTICE '======================================================================';

end;
$body$
    LANGUAGE 'plpgsql'
    VOLATILE
    RETURNS NULL ON NULL INPUT
    SECURITY INVOKER
    COST 100;

select public.criacao_tabelas_empreendimento();
drop function public.criacao_tabelas_empreendimento();