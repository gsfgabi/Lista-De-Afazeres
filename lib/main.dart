import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ToDoList(),
    ),
  );
}

class ToDoList extends StatefulWidget {
  const ToDoList({Key? key}) : super(key: key);

  @override
  State<ToDoList> createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  final TextEditingController _controlador = TextEditingController();
  final List<String> _tarefas = [];
  final List<bool> _tarefasConcluidas = [];

  @override
  void initState() {
    super.initState();
    _carregarTarefa();
  }

  void _salvarTarefa() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('tarefas', _tarefas);
  }

  void _carregarTarefa() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _tarefas.clear();
      _tarefasConcluidas.clear();
      List<String>? tarefasSalvas = prefs.getStringList('tarefas');
      if (tarefasSalvas != null) {
        for (int i = 0; i < tarefasSalvas.length; i++) {
          _tarefas.add(tarefasSalvas[i]);
          _tarefasConcluidas.add(false);
        }
      }
    });
  }

  void _adicionarTarefa() {
    setState(() {
      String novaTarefaTexto = _controlador.text;
      if (novaTarefaTexto.isNotEmpty) {
        _tarefas.add(novaTarefaTexto);
        _tarefasConcluidas.add(false);
        _controlador.clear();
        _salvarTarefa();
      }
    });
  }

  void _editarTarefa(int index) {
    String tarefaOriginal = _tarefas[index];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar tarefa'),
          content: TextField(
            controller: TextEditingController(text: _tarefas[index]),
            onChanged: (value) {
              setState(() {
                _tarefas[index] = value;
              });
            },
            decoration: const InputDecoration(labelText: 'Tarefa'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _tarefas[index] = tarefaOriginal;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _salvarTarefa();
                Navigator.of(context).pop();
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _excluirTarefa(int index) {
    setState(() {
      _tarefas.removeAt(index);
      _salvarTarefa();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC4E477),
      appBar: AppBar(
        title: const Center(child: Text('To-Do List')),
        backgroundColor: const Color(0xFF628A4C),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 30),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _tarefas.length,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Checkbox(
                      value: _tarefasConcluidas[index],
                      onChanged: (value) {
                        setState(() {
                          _tarefasConcluidas[index] = value ?? false;
                          _salvarTarefa();
                        });
                      },
                      checkColor: Colors.white,
                      activeColor: const Color(0xFF628A4C),
                    ),
                    Expanded(
                      child: Text(
                        _tarefas[index],
                        style: TextStyle(
                          decoration: _tarefasConcluidas[index]
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editarTarefa(index),
                      color: const Color(
                          0xFF628A4C), // Defina a cor do ícone de edição
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _excluirTarefa(index),
                      color: const Color(0xFF628A4C),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF628A4C),
        foregroundColor: Colors.white,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Adicionar Tarefa'),
                content: TextField(
                  controller: _controlador,
                  decoration: const InputDecoration(labelText: 'Tarefa'),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        color: Color(0xFF628A4C),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _adicionarTarefa();
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Adicionar',
                      style: TextStyle(
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
