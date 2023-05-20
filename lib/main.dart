import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_management/app_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false, // debugの帯を消す
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  //　アプリの復帰を検知する
  @override
  void initState() {
    super.initState();
    Future(() async {
      await AppProvider.checkLogIn();
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  List<Color> colorList = [
    Colors.redAccent,
    Colors.yellowAccent,
    Colors.greenAccent
  ];

  final appProviderInstance = AppProvider();

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AppProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('あなたのタスク'),
      ),
      //　FutureBuilderでタスクを読み込む
      body: FutureBuilder(
        // future: initialize(context),
        future: Provider.of<AppProvider>(context, listen: false).initialize(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            children: [
              // AppBarの余白
              const SizedBox(
                height: 25,
              ),
              // gitHubのような緑のグリッド
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.only(left: 18),
                margin: const EdgeInsets.only(left: 12, right: 12),
                height: MediaQuery.of(context).size.width * 0.5,
                child: GridView.builder(
                    scrollDirection: Axis.horizontal, // 縦横逆転させる
                    itemCount: 84,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisSpacing: 8, //ボックス左右間のスペース
                      mainAxisSpacing: 8, //ボックス上下間のスペース
                      crossAxisCount: 7, //ボックスを縦に並べる数 Axis.horizontalで上下逆
                    ),
                    itemBuilder: (context, index) {
                      return Center(
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green
                                  .withOpacity(vm.historyList[83 - index])),
                          height: 20,
                          width: 20,
                          // child: Text('${vm.historyList[83 - index]}'),
                          // child: Text('${83 - index}'),
                        ),
                      );
                    }),
              ),
              // 実際のタスク
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: vm.taskList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    margin: const EdgeInsets.only(left: 40, right: 40, top: 24),
                    child: ListTile(
                      // shape: RoundedRectangleBorder(
                      //   borderRadius: BorderRadius.circular(20),
                      // ),
                      leading: const Icon(Icons.task_outlined),
                      tileColor: colorList[vm.taskList[index].priority]
                          .withOpacity(0.7),
                      title: Text(vm.taskList[index].text),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) {
                            return AlertDialog(
                              title: const Text('タスクが完了しました。'),
                              content: const Text('削除しますか？'),
                              actions: <Widget>[
                                GestureDetector(
                                  child: const Text('いいえ'),
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                GestureDetector(
                                  child: const Text('はい'),
                                  onTap: () {
                                    appProviderInstance.removeTaskProvider(
                                        vm.taskList[index].key);
                                    setState(() {});
                                    Navigator.pop(context);
                                  },
                                )
                              ],
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddTask()));
        },
        tooltip: 'Add new Task',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _handleAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await AppProvider.checkLogIn();
      // print('this : $day');
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("Welcome back!"),
          content: Text("復帰しました！おかえりなさい"),
        ),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _handleAppLifecycleState(state);
  }
}

class AddTask extends StatelessWidget {
  final myController = TextEditingController();

  AddTask({super.key}); // input
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AppProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('タスクを追加'),
      ),
      body: Container(
        margin: const EdgeInsets.only(right: 30, left: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.width / 3,
            ),
            const Text('新しいタスクを入力してください。'),
            TextField(
              autofocus: true,
              controller: myController,
            ),
            const SizedBox(
              height: 32,
            ),
            const Text('優先度を選択してください。'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Radio<int>(
                  value: 0,
                  groupValue: vm.priority,
                  onChanged: (value) {
                    vm.tapRadio(value!);
                  },
                ),
                const Text('高'),
                Radio<int>(
                  value: 1,
                  groupValue: vm.priority,
                  onChanged: (value) {
                    vm.tapRadio(value!);
                  },
                ),
                const Text('中'),
                Radio<int>(
                  value: 2,
                  groupValue: vm.priority,
                  onChanged: (value) {
                    vm.tapRadio(value!);
                  },
                ),
                const Text('低'),
              ],
            ),
            TextButton(
              onPressed: () {
                vm.addTaskProvider(myController.text, vm.priority);
                vm.addHistoryNumber();
                vm.resetRadioPriority();
                Navigator.pop(context);
              },
              child: const Text('完了'),
            ),
          ],
        ),
      ),
    );
  }
}
