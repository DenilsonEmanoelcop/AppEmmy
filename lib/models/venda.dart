class Venda {
  final DateTime data;
  final double valor;
  final double entrada;
  final double restante;
  final String formaPagamento;

  Venda({
    required this.data,
    required this.valor,
    required this.entrada,
    required this.restante,
    required this.formaPagamento,
  });
}
