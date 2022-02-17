import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './widgets/new_transaction.dart';
import './widgets/transaction_list.dart';
import 'models/transaction.dart';
import './widgets/chart.dart';
import 'dart:io';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown
  // ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter App",
      theme: ThemeData(
        primarySwatch: Colors.orange,
        accentColor: Colors.red,
        fontFamily: "Quicksand",
        appBarTheme: AppBarTheme(
          titleTextStyle: TextStyle(
              fontFamily: "OpenSans",
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black),
        ),
        textTheme: ThemeData.light().textTheme.copyWith(
              headline6: TextStyle(
                fontFamily: "OpenSans",
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Transaction> transactions = [];

  // final List<Transaction> transactions = [
  //   Transaction(
  //       id: 't1', title: 'New Shoes', amount: 71.99, date: DateTime.now()),
  //   Transaction(
  //       id: 't2', title: 'Groceries', amount: 14.99, date: DateTime.now()),
  //   Transaction(id: 't1', title: 'Apple', amount: 0.99, date: DateTime.now())
  // ];

  List<Transaction> get _recentTransactions {
    return transactions.where((tx) {
      return tx.date.isAfter(DateTime.now().subtract(Duration(days: 7)));
    }).toList();
  }

  bool _showChart = false;

  void _addNewTransaction(String title, double amount, DateTime chosenDate) {
    final newTx = Transaction(
        id: DateTime.now().toString(),
        title: title,
        amount: amount,
        date: chosenDate);

    setState(() {
      transactions.add(newTx);
    });
  }

  bool get _keyboardIsVisible {
    return !(MediaQuery.of(context).viewInsets.bottom == 0.0);
  }

  void _startAddNewTransaction(BuildContext ctx) {
    // showModalBottomSheet(    //     context: ctx,
    //     builder: (bCtx) {
    //       return NewTransaction(addNewTraction: _addNewTransaction);
    //     });

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: _keyboardIsVisible
            ? MediaQuery.of(context).size.height * 0.4 +
                MediaQuery.of(context).viewInsets.bottom
            : MediaQuery.of(context).size.height * 0.4,
        decoration: new BoxDecoration(
          color: Colors.white,
          borderRadius: new BorderRadius.only(
            topLeft: const Radius.circular(25.0),
            topRight: const Radius.circular(25.0),
          ),
        ),
        child: Center(
          child: NewTransaction(addNewTraction: _addNewTransaction),
        ),
      ),
    );
  }

  void _deletetransaction(String id) {
    setState(() {
      transactions.removeWhere((element) => element.id == id);
    });
  }

  Widget _buildIosAppBar(double curScaleFactor) {
    return CupertinoNavigationBar(
      middle: Text("Flutter App",
      style: TextStyle(
        fontSize: 20 * curScaleFactor,
      ),),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            child: Icon(CupertinoIcons.add),
            onTap: () => _startAddNewTransaction(context),
          )
        ],
      ),
    );
  }

  Widget _buildAndroidAppBar(double curScaleFactor) {
    return AppBar(
      title: Text(
        "Flutter App",
        style: TextStyle(fontSize: 20 * curScaleFactor),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () => _startAddNewTransaction(context),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final curScaleFactor = mediaQuery.textScaleFactor;
    final isLandScape = mediaQuery.orientation == Orientation.landscape;

    final PreferredSizeWidget appBar =
        Platform.isIOS ? _buildIosAppBar(curScaleFactor) : _buildAndroidAppBar(curScaleFactor);

    final txList = Container(
      height: (mediaQuery.size.height -
              appBar.preferredSize.height -
              mediaQuery.padding.top) *
          0.7,
      child: TransactionList(
        transactions: transactions,
        deleteTransaction: _deletetransaction,
      ),
    );

    final pageBody = SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isLandScape)
              Container(
                height: (mediaQuery.size.height -
                        appBar.preferredSize.height -
                        mediaQuery.padding.top) *
                    0.07,
                margin: EdgeInsets.fromLTRB(0, 6, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Show Chart",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    Switch.adaptive(
                        value: _showChart,
                        onChanged: (val) {
                          setState(() {
                            _showChart = val;
                          });
                        }),
                  ],
                ),
              ),
            if (!isLandScape)
              Container(
                  margin: EdgeInsets.zero,
                  height: (mediaQuery.size.height -
                          appBar.preferredSize.height -
                          mediaQuery.padding.top) *
                      0.3,
                  child: Chart(
                    recentTransactions: _recentTransactions,
                  )),
            if (!isLandScape) txList,
            if (isLandScape)
              _showChart
                  ? Container(
                      margin: EdgeInsets.zero,
                      height: (mediaQuery.size.height -
                              appBar.preferredSize.height -
                              mediaQuery.padding.top) *
                          0.7,
                      child: Chart(
                        recentTransactions: _recentTransactions,
                      ))
                  : txList,
          ],
        ),
      ),
    );

    return Platform.isIOS
        ? CupertinoPageScaffold(
            child: pageBody,
            navigationBar: appBar,
          )
        : Scaffold(
            appBar: appBar,
            body: pageBody,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () => _startAddNewTransaction(context),
            ),
          );
  }
}
