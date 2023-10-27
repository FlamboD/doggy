import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dog Finder App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      home: const DogFinderPage(title: 'The Dog Finder'),
    );
  }
}

class DogFinderPage extends StatefulWidget {
  const DogFinderPage({super.key, required this.title});

  final String title;

  @override
  State<DogFinderPage> createState() => _DogFinderPageState();
}

class _DogFinderPageState extends State<DogFinderPage> {
  String? imageSrc;
  String? errorText;
  Map<String, List<String>> dogBreeds = {};
  String? selectedBreed;
  String? selectedSubBreed;
  TextEditingController breedTextController = TextEditingController();
  TextEditingController subBreedTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchDogBreeds();
    });
  }

  @override
  Widget build(BuildContext context) {
    double inputWidth = 500;
    List<DropdownMenuEntry> breedOptions = buildBreeds();
    List<DropdownMenuEntry> subBreedOptions = buildSubBreeds();

    bool validBreed = breedOptions
        .where((element) => element.value == breedTextController.text)
        .isNotEmpty;
    bool validSubBreed = subBreedOptions.isEmpty ||
        subBreedOptions
            .where((element) => element.value == subBreedTextController.text)
            .isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: separatedChildren(
                0,
                [
                  Image.asset(
                    'DefaultDog.jpg',
                  ),
                  SizedBox(
                    width: inputWidth,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: separatedChildren(16, [
                        DropdownMenu(
                          errorText: validBreed ||
                                  breedTextController.value.text.isEmpty
                              ? null
                              : 'Please select a valid breed',
                          controller: breedTextController,
                          onSelected: (breed) {
                            setState(() {
                              selectedBreed = breed;
                            });
                          },
                          width: inputWidth,
                          enableFilter: true,
                          dropdownMenuEntries: buildBreeds(),
                          label: const Text(
                            'Breed',
                          ),
                        ),
                        DropdownMenu(
                          onSelected: (subBreed) {
                            setState(() {
                              selectedSubBreed = subBreed;
                            });
                          },
                          controller: subBreedTextController,
                          enabled: subBreedOptions.isNotEmpty,
                          errorText: validSubBreed
                              ? null
                              : 'Please select a valid sub-breed',
                          width: inputWidth,
                          enableFilter: true,
                          dropdownMenuEntries: subBreedOptions,
                          label: const Text(
                            'Sub-breed',
                          ),
                        ),
                        ElevatedButton(
                          onPressed: validBreed && validSubBreed ? () {} : null,
                          child: const Padding(
                            padding: EdgeInsets.all(
                              16,
                            ),
                            child: Text('Dog searcher'),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: errorText != null,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: ColoredBox(
                color: Colors.red.withOpacity(0.2),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white),
                    child: SizedBox(
                      width: 250,
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(errorText ?? ''),
                            const SizedBox(height: 16),
                            ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    errorText = null;
                                  });
                                },
                                child: const Text('Reset'))
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // child: Center(
            //   child: SizedBox(
            //     width: 300,
            //     child: Column(
            //       children: [
            //         Text(errorText ?? ''),
            //         Center(
            //           child: ElevatedButton(
            //             onPressed: () {},
            //             child: const Text('Reset'),
            //           ),
            //         )
            //       ],
            //     ),
            //   ),
            // ),
          )
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ),
    );
  }

  List<DropdownMenuEntry> buildBreeds() {
    List<DropdownMenuEntry> entries = [];
    for (var entry in dogBreeds.entries) {
      entries.add(
        DropdownMenuEntry(value: entry.key, label: entry.key),
      );
    }
    return entries;
  }

  List<DropdownMenuEntry> buildSubBreeds() {
    if (selectedBreed == null) return [];
    if (dogBreeds[selectedBreed] == null) return [];
    if (dogBreeds[selectedBreed]!.isEmpty) return [];

    List<DropdownMenuEntry> entries = [
      const DropdownMenuEntry(value: null, label: 'Any')
    ];
    for (var breed in dogBreeds[selectedBreed]!) {
      entries.add(
        DropdownMenuEntry(value: breed, label: breed),
      );
    }
    return entries;
  }

  List<Widget> separatedChildren(double space, List<Widget> children,
      {Axis axis = Axis.vertical, bool applyToTartAndEnd = false}) {
    List<Widget> spacedChildren = [];
    if (applyToTartAndEnd) spacedChildren.add(spacer(space, axis));

    for (int i in List.generate(children.length, (index) => index)) {
      if (i != 0) spacedChildren.add(spacer(space, axis));
      spacedChildren.add(children[i]);
    }

    if (applyToTartAndEnd) spacedChildren.add(spacer(space, axis));
    return spacedChildren;
  }

  SizedBox spacer(double space, Axis axis) => SizedBox(
        width: axis == Axis.horizontal ? space : 0,
        height: axis == Axis.vertical ? space : 0,
      );

  Future fetchDogBreeds() async {
    Map<String, List<String>> breeds = {};

    final response =
        await http.get(Uri.parse('https://dog.ceo/api/breeds/list/all'));

    if (response.statusCode == 200) {
      for (var entry in (jsonDecode(response.body)["message"] as Map).entries) {
        breeds[entry.key] = (entry.value as List).cast<String>();
      }
    } else {
      errorText = 'Failed to fetch dog breeds';
    }
    dogBreeds = breeds;
  }

  Future fetchDog(String? breed, String? subBreed) async {
    String url = 'https://dog.ceo/api/breeds/image/random';

    if (breed != null) {
      url = 'https://dog.ceo/api/breed/$breed/images/random';
    }

    if (subBreed != null) {
      url = 'https://dog.ceo/api/breed/$breed/$subBreed/images/random';
    }

    final response =
        await http.get(Uri.parse('https://dog.ceo/api/breeds/list/all'));

    if (response.statusCode == 200) {
      setState(() {
        imageSrc = jsonDecode(response.body)["message"];
      });
    } else {
      setState(() {
        errorText = 'Failed to fetch image';
      });
    }
  }
}
