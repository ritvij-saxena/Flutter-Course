import 'package:demo1/models/product.dart';
import 'package:demo1/scoped_models/main.dart';
import 'dart:io';
import 'package:demo1/widgets/products/helper/ensure-visible.dart';
import 'package:demo1/widgets/products/ui_elements/adaptive_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:demo1/widgets/products/form_inputs/location.dart';
import 'package:demo1/models/location_data.dart';
import '../widgets/products/form_inputs/image.dart';
import 'package:flutter/cupertino.dart';

class ProductEditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProductEditState();
  }
}

class _ProductEditState extends State<ProductEditPage> {
  final Map<String, dynamic> _formData = {
    'title': null,
    'description': null,
    'price': null,
    'image': null,
    'location': null
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _titleFocusNode = new FocusNode();
  final _descriptionFocusNode = new FocusNode();
  final _priceFocusNode = new FocusNode();
  final _titleTextController = TextEditingController();
  final _descriptionTextController = TextEditingController();
  final _priceTextController = TextEditingController();

  Widget _buildTitleTextField(Product product) {
    if(product == null && _titleTextController.text.trim() == '')
    {
      _titleTextController.text='';
    }
    else if(product!=null && _titleTextController.text.trim() == '')
    {
      _titleTextController.text=product.title;
    }
    else if(product!=null && _titleTextController.text.trim()!='')
    {
        _titleTextController.text = _titleTextController.text;
    }
    else if(product == null && _titleTextController.text.trim()!='')
    {
      _titleTextController.text = _titleTextController.text;
    }
    return EnsureVisibleWhenFocused(
        focusNode: _titleFocusNode,
        child: TextFormField(
          controller: _titleTextController,
          focusNode: _titleFocusNode,
//          initialValue: product == null ? '' : product.title,
          decoration: InputDecoration(labelText: 'Product Title'),
          keyboardType: TextInputType.text,
          validator: (String value) {
            if (value.isEmpty || value.length < 3) {
              return 'Title required and minimum 3+ characters required';
            }
          },
          onSaved: (String value) {
            _formData['title'] = value;
          },
          /*onChanged: (String value) {

      }*/
        ));
  }

  Widget _buildDescriptionTextField(Product product) {
    if(product == null && _descriptionTextController.text.trim() == ''){
      _descriptionTextController.text='';
    }else if(product != null && _descriptionTextController.text.trim==''){
      _descriptionTextController.text=product.description;
    }
    return EnsureVisibleWhenFocused(
        focusNode: _descriptionFocusNode,
        child: TextFormField(
            focusNode: _descriptionFocusNode,
            decoration: InputDecoration(labelText: 'Product Description'),
            initialValue: product == null ? '' : product.description,
            maxLines: 4,
            keyboardType: TextInputType.text,
            validator: (String value) {
              if (value.isEmpty || value.length < 10) {
                return 'Description required and 10+ characters required';
              }
            },
            onSaved: (String value) {
              _formData['description'] = value;
            }
            /*onChanged: (String value) {

      },*/
            ));
  }

  Widget _buildPriceTextField(Product product) {
    if(product == null && _priceTextController.text.trim() == ''){
      _priceTextController.text='';
    }else if(product != null && _priceTextController.text.trim==''){
      _priceTextController.text=product.price.toString();
    }
    return EnsureVisibleWhenFocused(
        focusNode: _priceFocusNode,
        child: TextFormField(
            focusNode: _priceFocusNode,
            decoration: InputDecoration(labelText: 'Product Price'),
            initialValue: product == null ? '' : product.price.toString(),
            keyboardType: TextInputType.number,
            validator: (String value) {
              if (value.isEmpty ||
                  !RegExp(r'^(?:[1-9]\d*|0)?(?:[.,]\d+)?$').hasMatch(value) ||
                  double.parse(value) < 0) {
                return 'Price required';
              }
            },
            onSaved: (String value) {
              _formData['price'] = double.parse(value);
            }
            /*onChanged: (String value) {

      },*/
            ));
  }

  Widget _buildPageContent(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        margin: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              _buildTitleTextField(product),
              _buildDescriptionTextField(product),
              _buildPriceTextField(product),
              SizedBox(
                height: 10.0,
              ),
              LocationInput(_setLocation,product),
              SizedBox(
                height: 10.0,
              ),
              ImageInput(_setImage,product),
              SizedBox(
                height: 10.0,
              ),
              _buildSubmitButton()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return model.isLoading_
            ? Center(
              child: AdaptiveProgressIndicator()
        )
            : RaisedButton(
                child: Text('Save'),
                onPressed: () => _submitForm(
                    model.addProducts,
                    model.updateProduct,
                    model.selectProduct,
                    model.selectedProductIndex));
      },
    );
  }


  void _setLocation(LocationData locData){
    _formData['location'] = locData;
  }

  void _setImage(File image){
      _formData['image'] = image;
  }


  void _submitForm(
      Function addProduct, Function updateProduct, Function setSelectedProduct,
      [int selectProductIndex]) {
    if (!_formKey.currentState.validate() || (_formData['image'] == null && selectProductIndex == -1)) {
      return;
    }
    _formKey.currentState.save();
    if (selectProductIndex == -1) {
      addProduct(
          _titleTextController.text,
          _descriptionTextController.text,
          _formData['image'],
          double.parse(_priceTextController.text) ,
          _formData['location'])
          .then((bool success) {
            if(success){
              Navigator.pushReplacementNamed(context, '/products')
                  .then((_) => setSelectedProduct(null));
            }
            else
              {
                showDialog(context:context, builder: (BuildContext context){
                  return AlertDialog(
                    title: Text('Something went wrong!'),
                    content: Text('Please Try Again'),
                    actions: <Widget>[
                      FlatButton(onPressed: (){
                        Navigator.of(context).pop();
                      }, child: Text('Okay'))
                    ],
                  );
                });
              }
          
      });
    } else {
      updateProduct(
          _titleTextController.text,
          _descriptionTextController.text,
          _formData['image'],
         double.parse(_priceTextController.text) ,
          _formData['location']
      ).then((_) => Navigator.pushReplacementNamed(context, '/products')
          .then((_) => setSelectedProduct(null)));
    }
  }


  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      final Widget pageContent =
          _buildPageContent(context, model.selectedProduct);
      return model.selectedProductIndex == -1
          ? pageContent
          : Scaffold(
              appBar: AppBar(
                title: Text('Edit Product'),
              ),
              body: pageContent,
            );
    });
  }
}
