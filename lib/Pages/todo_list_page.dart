import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final _todoController = TextEditingController();
  List<Map<String, dynamic>> _todos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    try {
      final response = await Supabase.instance.client
          .from('todos')
          .select()
          .eq('user_id', Supabase.instance.client.auth.currentUser!.id)
          .order('created_at');
      setState(() {
        _todos = (response as List<dynamic>).cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      _showError('Error loading todos');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _handleTodoAction(Future<void> Function() action, String errorMessage) async {
    try {
      await action();
    } catch (e) {
      _showError(errorMessage);
    }
  }

  Future<void> _addTodo() => _handleTodoAction(() async {
    if (_todoController.text.isEmpty) return;
    final response = await Supabase.instance.client.from('todos').insert({
      'title': _todoController.text,
      'completed': false,
      'user_id': Supabase.instance.client.auth.currentUser!.id,
    }).select();
    setState(() {
      _todos.add(response.first as Map<String, dynamic>);
      _todoController.clear();
    });
  }, 'Error adding todo');

  Future<void> _toggleTodo(int index) => _handleTodoAction(() async {
    final todo = _todos[index];
    final response = await Supabase.instance.client
        .from('todos')
        .update({'completed': !todo['completed']})
        .eq('id', todo['id'])
        .select();
    setState(() => _todos[index] = response.first as Map<String, dynamic>);
  }, 'Error updating todo');

  Future<void> _deleteTodo(int index) => _handleTodoAction(() async {
    final todo = _todos[index];
    setState(() => _todos.removeAt(index));
    await Supabase.instance.client.from('todos').delete().eq('id', todo['id']);
    _showSuccess('Task deleted successfully');
  }, 'Error deleting todo');

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Widget _buildTodoItem(Map<String, dynamic> todo, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: todo['completed'] as bool,
          onChanged: (_) => _toggleTodo(index),
        ),
        title: Text(
          todo['title'] as String,
          style: TextStyle(
            decoration: todo['completed'] as bool ? TextDecoration.lineThrough : null,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteTodo(index),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _todoController,
                          decoration: const InputDecoration(
                            hintText: 'Add new task...',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _addTodo,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _todos.length,
                    itemBuilder: (context, index) => _buildTodoItem(_todos[index], index),
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }
}