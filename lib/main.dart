import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'login_screen.dart';
import 'validador_screen.dart';


part 'main.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(VendaAdapter());
  Hive.registerAdapter(ClienteAdapter());
  Hive.registerAdapter(ProdutoAdapter());
  await Hive.openBox<Venda>('vendas');
  await Hive.openBox<Cliente>('clientes');
  await Hive.openBox<Produto>('produtos');
  runApp(const MyApp());
}

@HiveType(typeId: 0)
class Venda extends HiveObject {
  @HiveField(0)
  DateTime data;

  @HiveField(1)
  double valor;

  @HiveField(2)
  double entrada;

  @HiveField(3)
  double restante;

  @HiveField(4)
  String formaPagamento;

  @HiveField(5)
  Cliente cliente;

  @HiveField(6)
  Produto produto;

  Venda({
    required this.data,
    required this.valor,
    required this.entrada,
    required this.restante,
    required this.formaPagamento,
    required this.cliente,
    required this.produto,
  });
}

@HiveType(typeId: 1)
class Cliente extends HiveObject {
  @HiveField(0)
  String nome;

  Cliente({required this.nome});
}

@HiveType(typeId: 2)
class Produto extends HiveObject {
  @HiveField(0)
  String descricao;
  
  @HiveField(1)
  double precoBase;

  Produto({required this.descricao, required this.precoBase});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  debugShowCheckedModeBanner: false,
  title: 'Controle de Vendas - Ótica',
  theme: ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A1A2E),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E1E2C),
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.indigo),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.blueAccent),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16),
      ),
    ),
    useMaterial3: true,
  ),
  initialRoute: '/validador',
  routes: {
    '/validador': (context) => const ValidadorScreen(),
    '/login': (context) => const LoginScreen(),
    '/': (context) => const CadastroVendaScreen(),
    '/consulta': (context) => const ConsultaVendaScreen(),
    '/relatorio': (context) => const RelatorioVendaScreen(),
  },
);

  }
}

class CadastroVendaScreen extends StatefulWidget {
  const CadastroVendaScreen({super.key});

  @override
  State<CadastroVendaScreen> createState() => _CadastroVendaScreenState();
}

class _CadastroVendaScreenState extends State<CadastroVendaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  final _entradaController = TextEditingController();
  final _clienteController = TextEditingController();
  final _produtoController = TextEditingController();
  final _precoBaseController = TextEditingController();
  double _restante = 0.0;
  String _formaPagamento = 'Pix';
  Cliente? _clienteSelecionado;
  Produto? _produtoSelecionado;

  void _calcularRestante() {
    final valor = double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0.0;
    final entrada = double.tryParse(_entradaController.text.replaceAll(',', '.')) ?? 0.0;
    setState(() {
      _restante = (valor - entrada).clamp(0, double.infinity);
    });
  }

  void _salvarVenda() async {
    if (_formKey.currentState!.validate() && _clienteSelecionado != null && _produtoSelecionado != null) {
      final valor = double.parse(_valorController.text.replaceAll(',', '.'));
      final entrada = double.parse(_entradaController.text.replaceAll(',', '.'));
      final data = DateTime.now();

      final novaVenda = Venda(
        data: data,
        valor: valor,
        entrada: entrada,
        restante: _restante,
        formaPagamento: _formaPagamento,
        cliente: _clienteSelecionado!,
        produto: _produtoSelecionado!,
      );

      final box = Hive.box<Venda>('vendas');
      await box.add(novaVenda);

      setState(() {
        _valorController.clear();
        _entradaController.clear();
        _restante = 0.0;
        _formaPagamento = 'Pix';
        _clienteSelecionado = null;
        _produtoSelecionado = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Venda salva com sucesso!')),
      );
    }
  }

  void _adicionarCliente() async {
    final nome = _clienteController.text.trim();
    if (nome.isNotEmpty) {
      final box = Hive.box<Cliente>('clientes');
      final cliente = Cliente(nome: nome);
      await box.add(cliente);
      setState(() {
        _clienteController.clear();
      });
    }
  }

  void _adicionarProduto() async {
    final descricao = _produtoController.text.trim();
    final precoBase = double.tryParse(_precoBaseController.text.replaceAll(',', '.')) ?? 0.0;
    
    if (descricao.isNotEmpty && precoBase > 0) {
      final box = Hive.box<Produto>('produtos');
      final produto = Produto(descricao: descricao, precoBase: precoBase);
      await box.add(produto);
      setState(() {
        _produtoController.clear();
        _precoBaseController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientes = Hive.box<Cliente>('clientes').values.toList();
    final produtos = Hive.box<Produto>('produtos').values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Venda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => Navigator.pushNamed(context, '/consulta'),
          ),
          IconButton(
            icon: const Icon(Icons.pie_chart),
            onPressed: () => Navigator.pushNamed(context, '/relatorio'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<Produto>(
                value: _produtoSelecionado,
                hint: const Text('Selecione um Produto'),
                decoration: const InputDecoration(labelText: 'Produto (Tipo de Lente)'),
                items: produtos
                    .map((p) => DropdownMenuItem(
                          value: p,
                          child: Text('${p.descricao} (R\$ ${p.precoBase.toStringAsFixed(2)})'),
                        ))
                    .toList(),
                onChanged: (p) {
                  setState(() {
                    _produtoSelecionado = p;
                    if (p != null) {
                      _valorController.text = p.precoBase.toStringAsFixed(2);
                      _calcularRestante();
                    }
                  });
                },
                validator: (value) => value == null ? 'Selecione um produto' : null,
              ),

              const SizedBox(height: 12),
              const Text('Cadastrar Novo Produto:'),
              TextFormField(
                controller: _produtoController,
                decoration: const InputDecoration(labelText: 'Descrição do Produto'),
              ),
              TextFormField(
                controller: _precoBaseController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Preço Base'),
              ),
              ElevatedButton(
                onPressed: _adicionarProduto,
                child: const Text('Adicionar Produto'),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _valorController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Valor da Venda'),
                onChanged: (_) => _calcularRestante(),
                validator: (value) => value == null || value.isEmpty ? 'Informe o valor' : null,
              ),
              TextFormField(
                controller: _entradaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Entrada'),
                onChanged: (_) => _calcularRestante(),
                validator: (value) => value == null || value.isEmpty ? 'Informe a entrada' : null,
              ),
              const SizedBox(height: 12),
              Text('Restante: R\$ ${_restante.toStringAsFixed(2)}'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _formaPagamento,
                decoration: const InputDecoration(labelText: 'Forma de Pagamento'),
                items: ['Pix', 'Dinheiro', 'Cartão Débito', 'Cartão Crédito']
                    .map((fp) => DropdownMenuItem(value: fp, child: Text(fp)))
                    .toList(),
                onChanged: (value) => setState(() => _formaPagamento = value!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Cliente>(
                value: _clienteSelecionado,
                hint: const Text('Selecione um Cliente'),
                decoration: const InputDecoration(labelText: 'Cliente'),
                items: clientes
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.nome),
                        ))
                    .toList(),
                onChanged: (c) => setState(() => _clienteSelecionado = c),
                validator: (value) => value == null ? 'Selecione um cliente' : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _clienteController,
                      decoration: const InputDecoration(labelText: 'Novo Cliente'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _adicionarCliente,
                  )
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvarVenda,
                child: const Text('Salvar Venda'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ConsultaVendaScreen extends StatefulWidget {
  const ConsultaVendaScreen({super.key});

  @override
  State<ConsultaVendaScreen> createState() => _ConsultaVendaScreenState();
}

class _ConsultaVendaScreenState extends State<ConsultaVendaScreen> {
  String buscaCliente = '';
  DateTime? dataInicio;
  DateTime? dataFim;
  String filtroRestante = 'Todos';

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Venda>('vendas');
    final todasVendas = box.values.toList();

    final vendasFiltradas = todasVendas.where((v) {
      final nomeCliente = v.cliente.nome.toLowerCase();
      final data = v.data;

      final correspondeNome = nomeCliente.contains(buscaCliente.toLowerCase());
      final dentroDoPeriodo = (dataInicio == null || data.isAfter(dataInicio!.subtract(const Duration(days: 1)))) &&
                              (dataFim == null || data.isBefore(dataFim!.add(const Duration(days: 1))));
      final condicaoRestante = switch (filtroRestante) {
        'Com valor restante' => v.restante > 0,
        'Pagos' => v.restante <= 0,
        _ => true,
      };

      return correspondeNome && dentroDoPeriodo && condicaoRestante;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Consulta de Vendas')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar por cliente',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() => buscaCliente = value);
              },
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: Text(dataInicio == null
                        ? 'Data início'
                        : DateFormat('dd/MM/yyyy').format(dataInicio!)),
                    onPressed: () async {
                      final dataSelecionada = await showDatePicker(
                        context: context,
                        initialDate: dataInicio ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (dataSelecionada != null) {
                        setState(() => dataInicio = dataSelecionada);
                      }
                    },
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: Text(dataFim == null
                        ? 'Data fim'
                        : DateFormat('dd/MM/yyyy').format(dataFim!)),
                    onPressed: () async {
                      final dataSelecionada = await showDatePicker(
                        context: context,
                        initialDate: dataFim ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (dataSelecionada != null) {
                        setState(() => dataFim = dataSelecionada);
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: filtroRestante,
              decoration: const InputDecoration(labelText: 'Filtro de pagamento'),
              items: const [
                DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                DropdownMenuItem(value: 'Com valor restante', child: Text('Com valor restante')),
                DropdownMenuItem(value: 'Pagos', child: Text('Pagos')),
              ],
              onChanged: (value) {
                setState(() => filtroRestante = value!);
              },
            ),

            const SizedBox(height: 12),

            Expanded(
              child: vendasFiltradas.isEmpty
                  ? const Center(child: Text('Nenhuma venda encontrada.'))
                  : ListView.builder(
                      itemCount: vendasFiltradas.length,
                      itemBuilder: (context, index) {
                        final venda = vendasFiltradas[index];
                        return ListTile(
                          title: Text('${venda.cliente.nome} - ${venda.produto.descricao}'),
                          subtitle: Text(
                            '${DateFormat('dd/MM/yyyy').format(venda.data)}\n'
                            'Valor: R\$ ${venda.valor.toStringAsFixed(2)}',
                          ),
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(venda.formaPagamento),
                              Text('Restante: R\$ ${venda.restante.toStringAsFixed(2)}'),
                            ],
                          ),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditarVendaScreen(venda: venda),
                              ),
                            );
                            setState(() {});
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}



class RelatorioVendaScreen extends StatelessWidget {
  const RelatorioVendaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Venda>('vendas');
    final vendas = box.values.toList();

    final Map<String, double> totais = {
      'Pix': 0.0,
      'Dinheiro': 0.0,
      'Cartão Débito': 0.0,
      'Cartão Crédito': 0.0,
    };

    double totalRestante = 0.0;

    for (var v in vendas) {
      totais[v.formaPagamento] = (totais[v.formaPagamento] ?? 0) + v.valor;
      totalRestante += v.restante;
    }

    final formas = totais.keys.toList();
    final List<BarChartGroupData> barGroups = List.generate(formas.length, (i) {
      final valor = totais[formas[i]] ?? 0.0;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: valor,
            color: Colors.indigo,
            width: 20,
            borderRadius: BorderRadius.circular(4),
          )
        ],
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Relatório de Vendas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Totais por forma de pagamento', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  maxY: (totais.values.reduce((a, b) => a > b ? a : b)) + 50,
                  barGroups: barGroups,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 42),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            formas[value.toInt()],
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Total de Restante a Pagar: R\$ ${totalRestante.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class EditarVendaScreen extends StatefulWidget {
  final Venda venda;
  const EditarVendaScreen({super.key, required this.venda});

  @override
  State<EditarVendaScreen> createState() => _EditarVendaScreenState();
}

class _EditarVendaScreenState extends State<EditarVendaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pagamentoController = TextEditingController();

  @override
  void dispose() {
    _pagamentoController.dispose();
    super.dispose();
  }

  void _atualizarVenda() async {
    if (_formKey.currentState!.validate()) {
      double novoPagamento = double.tryParse(_pagamentoController.text.replaceAll(',', '.')) ?? 0.0;

      setState(() {
        widget.venda.entrada += novoPagamento;
        widget.venda.restante = (widget.venda.valor - widget.venda.entrada).clamp(0, double.infinity);
      });

      await widget.venda.save();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pagamento atualizado com sucesso!')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Venda')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cliente: ${widget.venda.cliente.nome}'),
              Text('Produto: ${widget.venda.produto.descricao}'),
              const SizedBox(height: 8),
              Text('Valor total: R\$ ${widget.venda.valor.toStringAsFixed(2)}'),
              Text('Entrada atual: R\$ ${widget.venda.entrada.toStringAsFixed(2)}'),
              Text('Restante atual: R\$ ${widget.venda.restante.toStringAsFixed(2)}'),
              const SizedBox(height: 20),
              TextFormField(
                controller: _pagamentoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Pagamento adicional'),
                validator: (value) {
                  double? val = double.tryParse(value!.replaceAll(',', '.'));
                  if (val == null || val <= 0) return 'Informe um valor válido';
                  if (val > widget.venda.restante) return 'Pagamento excede o valor restante';
                  return null;
                },
              ), 
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _atualizarVenda,
                child: const Text('Salvar Pagamento'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
