unit UConstantesDGE;

interface

const
  VERSION_NUMBER = '1.0.3.5';

  MODELO_NFE = 55;

  SEGMENTO_PADRAO_ID         = 0;
  SEGMENTO_VAREJO_ATACADO_ID = 1;
  SEGMENTO_MERCADO_CARRO_ID  = 2;

  TIPO_LOG_TRANS_NOTIFIC = 0;
  TIPO_LOG_TRANS_SEFA    = 1;
  TIPO_LOG_TRANS_SISTEMA = 2;

  DESC_LOG_INUTILIZA_NRO_NFE      = 'Inutiliza��o de numer�o para NF-e';
  DESC_LOG_CONSULTAR_NRO_LOTE_NFE = 'Consultar retorno do Lote/Recibo de NF-e';

  SEGMENTO_PADRAO_DS         = 'Padr�o';
  SEGMENTO_VAREJO_ATACADO_DS = 'Varejo e Atacado';
  SEGMENTO_MERCADO_CARRO_DS  = 'Com�rcio de Ve�culos';

  BOLETO_ARQUIVO_LOGOTIPO = 'Imagens\Emitente.gif';
  BOLETO_IMAGENS          = 'Imagens\';
  BOLETO_LICENCAS         = 'Licencas\';

  LAYOUT_BOLETO_ENTREGA = 'Boleto\Boleto.fr3';
  LAYOUT_BOLETO_CARNE   = 'Boleto\BoletoCarne.fr3';

  CODIGO_BANCO_BRASIL    = 1;
  CODIGO_BANCO_BRADESCO  = 237;
  CODIGO_BANCO_CAIXA     = 104;
  CODIGO_BANCO_HSBC      = 399;
  CODIGO_BANCO_ITAU      = 341;
  CODIGO_BANCO_SANTANDER = 33;

  PORTA_SMTP_PADRAO = 587;

implementation

end.
