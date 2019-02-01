import 'package:demo1/models/product.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImageInput extends StatefulWidget {
  final Function setImage;
  final Product product;

  ImageInput(this.setImage,this.product);
  @override
  State<StatefulWidget> createState() {
    return _ImageInputState();
  }
}

class _ImageInputState extends State<ImageInput> {
  File _image;

  void _getImage(BuildContext context, ImageSource imagesrc) {
    ImagePicker.pickImage(source: imagesrc, maxWidth: 400.0).then((File image) {
      setState(() {
        _image = image;
      });
      Navigator.pop(context);
    });
  }

  void _openImagePicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 150.0,
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Text('Pick Image',
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold)),
                SizedBox(
                  height: 10.0,
                ),
                FlatButton(
                  child: Text('Use Camera'),
                  onPressed: () {
                    _getImage(context, ImageSource.camera);
                  },
                ),
                FlatButton(
                  child: Text('Use Gallery'),
                  onPressed: () {
                    _getImage(context, ImageSource.gallery);
                  },
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    Widget previewImage = Text('Please select Image');
    if(_image!=null){
      previewImage = Image.file(_image,
          fit: BoxFit.cover,
          height: 300.0,
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.topCenter);
    } else if(widget.product != null) {
        previewImage = Image.network(widget.product.imageURL, fit: BoxFit.cover,
            height: 300.0,
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.topCenter);
    }
    return Column(
      children: <Widget>[
        OutlineButton(
            onPressed: () {
              _openImagePicker(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.camera_alt),
                SizedBox(
                  width: 5.0,
                ),
                Text('Add Image')
              ],
            )),
        SizedBox(height: 10.0),
        previewImage
      ],
    );
  }
}
