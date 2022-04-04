
import 'package:cometchat/main/cometchat.dart';
import 'package:flutter/material.dart';

class CreatePoll extends StatefulWidget {
  final Function(String question , List<String> options) pollFunc;
  const CreatePoll({Key? key, required this.pollFunc}) : super(key: key);

  @override
  _CreatePollState createState() => _CreatePollState();
}

class _CreatePollState extends State<CreatePoll> {
  String _question="";
  List<String> _answers = [""];
  final _pollKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          color: Color(0xff3399FF),
          onPressed: (){
            Navigator.of(context).pop();

          },
        ),
        title: const Text("CreatePolls"),
        actions: [IconButton(onPressed: ()async {

          await widget.pollFunc(_question,_answers);
          Navigator.of(context).pop();


        },
            icon: const Icon(Icons.check,
            color: Color(0xff3399FF),
            )

        )],


      ),
      body: SingleChildScrollView(


        child: Form(
          key: _pollKey,
          child: Column(
            children: [

              Padding(
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  onChanged: (String val){
                    _question = val;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Question',
                    hintText: 'Enter Question to Poll',
                  ),
                ),
              ),

              Text("Set the answers", style: TextStyle(
                color: Color(0xff141414).withOpacity(0.5) ,
                fontSize: 13
              ),),

              Column(
                children:  List.generate(_answers.length, (index) => getTextKey(index)),
              ),

               GestureDetector(
                 onTap: (){
                   _answers.add("");
                   setState(() {
                   });
                 },
                 child: const Text("Add Another Answer" ,  style: TextStyle(
                  color: Color(0xff3399FF)
              ),
              ),
               ),



            ],

          ),
        ),


      ),

    );
  }


getTextKey(int index){
    return Padding(
      padding: const EdgeInsets.all(15),
      child: TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
        onChanged: (String val){
         _answers[index] = val;
        },
        decoration:  InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Answer ${index+1}',
          hintText: 'Enter Answer ${index+1}',
        ),
      ),
    );

}


}
