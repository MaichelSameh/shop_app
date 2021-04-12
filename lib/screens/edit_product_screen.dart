import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const String routeName = "/edit-product";

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  final _imageUrlController = new TextEditingController();

  var _editedProduct = Product(
    id: null,
    title: "",
    description: "",
    imageUrl: "",
    price: 0,
  );

  var _initalValue = {
    "title": "",
    "description": "",
    "imageUrl": "",
    "price": 0.0,
  };

  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _imageUrlFocusNode.addListener(_updateImageUrl);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProduct = context.read<Products>().findByID(productId);
        _initalValue = {
          "title": _editedProduct.title,
          "description": _editedProduct.description,
          "imageUrl": "",
          "price": _editedProduct.price,
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
      _isInit = false;
    }
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (_imageUrlFocusNode.hasFocus) {
      if (!(_imageUrlController.text.startsWith("http") &&
              _imageUrlController.text.startsWith("https")) &&
          !_imageUrlController.text.endsWith(".png") &&
          !_imageUrlController.text.endsWith(".jpg") &&
          !_imageUrlController.text.endsWith(".jpeg")) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState.validate();
    if (!isValid) return;
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != null) {
      await context
          .read<Products>()
          .updateProduct(_editedProduct.id, _editedProduct);
    } else {
      try {
        await context.read<Products>().addProduct(_editedProduct);
        // _imageUrlController.clear();
      } catch (e) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("An error occured"),
            content: Text("Something went wrong."),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text("Okay!")),
            ],
          ),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edite Product"),
        actions: [
          IconButton(icon: Icon(Icons.save), onPressed: _saveForm),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initalValue['title'],
                      decoration: InputDecoration(labelText: "Title"),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return "please provide a value.";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          title: value,
                          description: _editedProduct.description,
                          imageUrl: _editedProduct.imageUrl,
                          price: _editedProduct.price,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initalValue['price'].toString(),
                      decoration: InputDecoration(labelText: "Price"),
                      textInputAction: TextInputAction.next,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return "please provide a price.";
                        }
                        if (double.tryParse(value) == null) {
                          return "Please Enter a valid number";
                        }
                        // try {
                        //   double.parse(value);
                        // } catch (e) {
                        //   return "Please Enter a valid price";
                        // }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          description: _editedProduct.description,
                          imageUrl: _editedProduct.imageUrl,
                          price: double.parse(value),
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                      keyboardType: TextInputType.number,
                    ),
                    TextFormField(
                      initialValue: _initalValue['description'],
                      decoration: InputDecoration(labelText: "Description"),
                      textInputAction: TextInputAction.next,
                      focusNode: _descriptionFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_imageUrlFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return "please provide a description.";
                        }
                        if (value.length < 10) {
                          return "Should be at least 10 character long.";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          description: value,
                          imageUrl: _editedProduct.imageUrl,
                          price: _editedProduct.price,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                      keyboardType: TextInputType.multiline,
                    ),
                    Row(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? Center(child: Text("Enter a URL"))
                              : FittedBox(
                                  child:
                                      Image.network(_imageUrlController.text),
                                  fit: BoxFit.cover),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _imageUrlController,
                            decoration: InputDecoration(labelText: "Image URL"),
                            textInputAction: TextInputAction.next,
                            focusNode: _imageUrlFocusNode,
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Please enter an image URL.";
                              }
                              if (!value.startsWith("http") &&
                                  !value.startsWith("https")) {
                                return "Please enter a valid URL.";
                              }
                              if (!value.endsWith(".png") &&
                                  value.endsWith(".jpg") &&
                                  value.endsWith(".jpeg")) {
                                return "Please enter a valid image URL.";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _editedProduct = Product(
                                id: _editedProduct.id,
                                title: _editedProduct.title,
                                description: _editedProduct.description,
                                imageUrl: value,
                                price: _editedProduct.price,
                                isFavorite: _editedProduct.isFavorite,
                              );
                            },
                            keyboardType: TextInputType.url,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
