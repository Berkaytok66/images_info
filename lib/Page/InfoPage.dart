
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:images_info/Page/SelectFile.dart';
import 'package:share/share.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class InfoPage extends StatefulWidget {
  final XFile image;


  const InfoPage({Key? key, required this.image}) : super(key: key);

  @override
  State<InfoPage> createState() => _InfoPageState();
}
///ca-app-pub-2801775263993120/4498822012
class _InfoPageState extends State<InfoPage> {
  List<Marker> infolist =<Marker> [];
  final Set<Marker> _markers = {};
  var imgDateTimeOriginal;
  var model;
  var ImageMakeMarka;
  var ImageCihazName;
  var GPSGPSDateTarih;
  late RewardedAd myRewardedAd;
  bool isAdLoaded = false;
  late XFile _image; // Durum değişkeni olarak tanımla
  final TextEditingController _controllerAdres = TextEditingController();
  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917', // Test ID, gerçek uygulamanız için kendi adUnitId'nizi kullanın
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          print('Ödüllü Reklam Yüklendi');
          setState(() {
            myRewardedAd = ad;
            isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Ödüllü Reklam Yüklenemedi: $error');
          isAdLoaded = false;
        },
      ),
    );
  }

  Completer<GoogleMapController> _haritaKontrol = Completer();
  CameraPosition _konum = CameraPosition(
    target: LatLng(0.758041, 1.1789993), // Geçici bir başlangıç konumu.
    zoom: 0.5,
  );

  @override
  void initState() {
    super.initState();
    _image = widget.image; // Başlangıçta widget'tan gelen değer ile başlat
    _readSpecificExifFromImage(_image);
    _controllerAdres.text="Konum Bulunamadı";
    loadRewardedAd();
  }
  void showRewardedAd() {
    if (isAdLoaded) {
      myRewardedAd.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          // Ödüllü reklam izlendikten sonra yapılacak işlemler
          removeExifAndSaveNewImage(File(_image.path));
        },
      );

      // Reklam gösterimi tamamlandıktan sonra yeni bir reklam yüklemek için:
      myRewardedAd.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (AdWithoutView ad) {
          ad.dispose();
          loadRewardedAd(); // Yeni reklamı yükle
        },
        onAdFailedToShowFullScreenContent: (AdWithoutView ad, AdError error) {
          ad.dispose();
          loadRewardedAd(); // Hata durumunda yeni reklamı yükle
        },
      );
    } else {
      print('Reklam henüz yüklenmedi');
      // Reklam yüklenmediyse doğrudan galeriden resim seçme işlemi yapılabilir.
      removeExifAndSaveNewImage(File(_image.path));
    }
  }
  Future<void> pickImageFromGallery() async {
    final XFile? newImage = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (newImage != null) {
    setState(() {
      _image = newImage; // Durum değişkenini güncelle
      _readSpecificExifFromImage(newImage);
    });

    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.only(bottomRight: Radius.circular(264.0)),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              child: GoogleMap(
                mapType: MapType.terrain,
                markers: _markers,
                initialCameraPosition: _konum,
                onMapCreated: (GoogleMapController controller) {
                  _haritaKontrol.complete(controller);
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height * 0.4,
              width: double.infinity,
              padding: EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                
                  mainAxisAlignment: MainAxisAlignment.spaceAround, // Kartları eşit şekilde dağıt
                  children: [
                    customDividerWithText("İşlemler"),
                    SizedBox(height: 5,),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Card(
                          color: Colors.white,
                          child: InkWell(
                            onTap: () {
                             // Navigator.push(
                             //   context,
                             //   MaterialPageRoute(builder: (context) => SelectFile()),
                             // );
                              pickImageFromGallery();
                            },
                            child: Container(

                              width: MediaQuery.of(context).size.width * 1, // Konteyner genişliği
                              height: MediaQuery.of(context).size.height * 0.06, // Konteyner yüksekliği
                              padding: EdgeInsets.all(6.0), // İç padding
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween, // İçeriği merkeze al
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(Icons.navigate_next,color: Colors.black,),
                                  ),
                                  Text(
                                    "Resim Seç",
                                    style: TextStyle(fontSize: 18,color: Colors.black),
                                    textAlign: TextAlign.center,
                                  ), // Metin
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(Icons.photo_size_select_large_outlined,color: Colors.black,),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Card(
                          color: Colors.greenAccent,
                          child: InkWell(
                            onTap: () {
                              // Buraya tıklandığında gerçekleşmesini istediğiniz işlevi yazın.
                              // Örneğin, bir metni paylaşmak için:
                              final String textToShare = "Fotoğraf Bilgiileri \nKonum : ${_controllerAdres.text ?? "Konum Boş"}\nModel : ${ImageMakeMarka?.toString() ?? "Model Koduna Erişilemedi"}\nModel Kodu : ${model?.toString() ?? "Model Koduna Erişilemedi"}\nCihaz İsmi: ${ImageCihazName?.toString()??"Cihaz İsmine Erişilemedi"}\nTarih Ve Saat Bilgisi : ${imgDateTimeOriginal?.toString()??"Tarih Ve Saat Bilgisine Ulaşılamadı"}";
                              Share.share(textToShare);
                            },
                            child: Container(

                              width: MediaQuery.of(context).size.width * 1, // Konteyner genişliği
                              height: MediaQuery.of(context).size.height * 0.06, // Konteyner yüksekliği
                              padding: EdgeInsets.all(6.0), // İç padding
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween, // İçeriği merkeze al
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(Icons.navigate_next,color: Colors.white,),
                                  ),
                                  Text(
                                    "Bilgileri Paylaş",
                                    style: TextStyle(fontSize: 18,color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ), // Metin
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(Icons.share,color: Colors.white,),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Card(
                          color: Colors.deepOrange,
                          child: InkWell(
                            onTap: () {
                              // Buraya tıklandığında gerçekleşmesini istediğiniz işlevi yazın.
                              // Örneğin, bir metni paylaşmak için:

                              showConfirmationDialog();
                            },
                            child: Container(

                              width: MediaQuery.of(context).size.width * 1, // Konteyner genişliği
                              height: MediaQuery.of(context).size.height * 0.06, // Konteyner yüksekliği
                              padding: EdgeInsets.all(6.0), // İç padding
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween, // İçeriği merkeze al
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(Icons.navigate_next,color: Colors.white,),
                                  ),
                                  Text(
                                    "Sil ve Paylaş",
                                    style: TextStyle(fontSize: 18,color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(Icons.cleaning_services_outlined,color: Colors.white,),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5,),
                    customDividerWithText("Detaylar"),
                    SizedBox(height: 5,),
                    Card(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9, // Konteyner genişliği
                        height: MediaQuery.of(context).size.height * 0.1, // Konteyner yüksekliği
                        padding: EdgeInsets.all(6.0), // İç padding
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, // İçeriği kenarlara yay
                          children: [

                            Expanded(
                              // TextField'ı Expanded widget'ı içine alarak kalan alanı doldurmasını sağla
                              child: TextField(
                                controller: _controllerAdres,
                                readOnly: true,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Konum',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9, // Konteyner genişliği
                        height: MediaQuery.of(context).size.height * 0.07, // Konteyner yuksekliği
                        padding: EdgeInsets.all(16.0), // İç padding
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, // İçeriği merkeze al
                          children: [
                            const Row(
                              children: [
                                Icon(CupertinoIcons.device_phone_portrait, size: 20),
                                SizedBox(width: 5),
                                Text("Üretici :",style:TextStyle(fontSize: 18) ,textAlign: TextAlign.center,),
                              ],
                            ), // İkon
                            const SizedBox(height: 8), // İkon ile metin arasında boşluk
                            Text(ImageMakeMarka?.toString() ?? 'Bulunamadı.'
                            ,style:const TextStyle(fontSize: 18) ,textAlign: TextAlign.center,), // İçerik dolduğu), // Metin
                          ],
                        ),
                      ),
                    ),
                    Card(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9, // Konteyner genişliği
                        height: MediaQuery.of(context).size.height * 0.07, // Konteyner yuksekliği
                        padding: EdgeInsets.all(16.0), // İç padding
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, // İçeriği merkeze al
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.phonelink_setup_rounded, size: 20),
                                SizedBox(width: 5),
                                Text("Model :",style:TextStyle(fontSize: 18) ,textAlign: TextAlign.center,),
                              ],
                            ), // İkon
                            const SizedBox(height: 8), // İkon ile metin arasında boşluk
                            Text(model?.toString() ?? "Bulunamadı."
                              ,style:const TextStyle(fontSize: 18) ,textAlign: TextAlign.center,), // Metin
                          ],
                        ),
                      ),
                    ),
                    Card(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9, // Konteyner genişliği
                        height: MediaQuery.of(context).size.height * 0.07, // Konteyner yuksekliği
                        padding: EdgeInsets.all(16.0), // İç padding
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, // İçeriği merkeze al
                          children: [
                           const Row(
                              children: [
                                Icon(Icons.phone_iphone_rounded, size: 20),
                                SizedBox(width: 5),
                                Text("Cihaz :",style:TextStyle(fontSize: 18) ,textAlign: TextAlign.center,)
                              ],
                            ), // İkon
                            const SizedBox(height: 8), // İkon ile metin arasında boşluk
                            Text(ImageCihazName?.toString()??'Bulunamadı.'
                              ,style:const TextStyle(fontSize: 18) ,textAlign: TextAlign.center,), // Metin
                          ],
                        ),
                      ),
                    ),
                    Card(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9, // Konteyner genişliği
                        height: MediaQuery.of(context).size.height * 0.07, // Konteyner yuksekliği
                        padding:const EdgeInsets.all(16.0), // İç padding
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, // İçeriği merkeze al
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.work_history_outlined, size: 20),
                                SizedBox(width: 5),
                                Text("Tarih :",style:TextStyle(fontSize: 18) ,textAlign: TextAlign.center,),
                              ],
                            ), // İkon
                            const SizedBox(height: 8), // İkon ile metin arasında boşluk
                            Text(GPSGPSDateTarih?.toString()??'Bulunamadı.'
                              ,style:const TextStyle(fontSize: 18) ,textAlign: TextAlign.center,), // Metin
                          ],
                        ),
                      ),
                    ),
                    Card(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9, // Konteyner genişliği
                        height: MediaQuery.of(context).size.height * 0.07, // Konteyner yuksekliği
                        padding:const EdgeInsets.all(16.0), // İç padding
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, // İçeriği merkeze al
                          children: [
                            const Row(
                              children: [
                                Icon(CupertinoIcons.time, size: 20),
                                SizedBox(width: 5),
                                Text("Tarih ve Saat :",style:TextStyle(fontSize: 18) ,textAlign: TextAlign.center,),
                              ],
                            ), // İkon
                            const SizedBox(height: 8), // İkon ile metin arasında boşluk
                            Text(imgDateTimeOriginal?.toString()??'Bulunamadı.'
                              ,style:const TextStyle(fontSize: 16) ,textAlign: TextAlign.center,), // Metin
                          ],
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),

          Positioned(
            right: 0, // Sağ üst köşeye yakın bir konum
            top: MediaQuery.of(context).size.height * 0.5 - 50, // Yukarıdaki Container'ın yarısından biraz yukarıda
            child: SizedBox(
              width: 150,
              height: 150,
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        backgroundColor: Colors.transparent,
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: <Widget>[
                            InteractiveViewer( // Resmi yakınlaştırma/uzaklaştırma için kullanılır
                              panEnabled: false, // Pan hareketini devre dışı bırak
                              boundaryMargin: EdgeInsets.all(80),
                              minScale: 0.5,
                              maxScale: 4,
                              child: Image.file(File(_image.path)),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.white), // 'X' ikonu
                              onPressed: () {
                                Navigator.of(context).pop(); // Diyalogu kapat
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: ClipOval(
                  child: Image.file(
                    File(_image.path),
                    fit: BoxFit.cover, // Resmi tam sığdırmak için
                  ),
                ),
              ),
            ),
          ),



        ],
      ),
    );
  }


  Future<void> _readSpecificExifFromImage(XFile image) async {
    final File file = File(image.path);
    final bytes = await file.readAsBytes();
    final data = await readExifFromBytes(bytes);

    if (data.isEmpty) {
      print("No EXIF information found");
      return;
    }

    final gpsLatitudeTag = data['GPS GPSLatitude']; // 'GPS GPSLatitude' yerine 'GPSLatitude'
    final gpsLongitudeTag = data['GPS GPSLongitude']; // 'GPS GPSLongitude' yerine 'GPSLongitude'

    if (gpsLatitudeTag != null && gpsLongitudeTag != null) {
      // gpsLatitudeTag ve gpsLongitudeTag değerlerinin `List<dynamic>` olduğunu varsayıyoruz.
      final latitude = _convertToDecimalDegrees(gpsLatitudeTag.values.toList());
      final longitude = _convertToDecimalDegrees(gpsLongitudeTag.values.toList());
      print("---------------------------------------------------------------: $latitude");
      print("---------------------------------------------------------------: $longitude");
      getPlaceAddress(latitude,longitude);
      final Marker marker = Marker(
        markerId: MarkerId("photo_marker"),
        position: LatLng(latitude, longitude), // _convertToDecimalDegrees'ten gelen koordinatlar
        infoWindow: InfoWindow(title: "Fotografın Konumu")
      );
      // Yeni konumu belirle
      CameraPosition yeniKonum = CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 17,
      );
      setState(() {

        _konum = yeniKonum;
        _markers.add(marker);

        imgDateTimeOriginal = data['Image DateTime'];
        model = data['Image Model'];
        ImageMakeMarka = data['Image Make'];
        ImageCihazName = data['Image Tag 0x9A00'];
        GPSGPSDateTarih = data['GPS GPSDate'];
      });

      // Harita kontrolcüsü üzerinde yeni konuma animasyon yap
      final GoogleMapController controller = await _haritaKontrol.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(yeniKonum));
    }
  }
  double _convertToDecimalDegrees(List<dynamic> values) {
    double degrees = 0.0;
    double minutes = 0.0;
    double seconds = 0.0;

    // Dereceleri işle
    if (values[0] is num) {
      degrees = (values[0] as num).toDouble();
    } else if (values[0] is Ratio) {
      degrees = (values[0] as Ratio).toDouble();
    }

    // Dakikaları işle
    if (values[1] is num) {
      minutes = (values[1] as num).toDouble();
    } else if (values[1] is Ratio) {
      minutes = (values[1] as Ratio).toDouble();
    }

    // Saniyeleri işle
    if (values[2] is num) {
      seconds = (values[2] as num).toDouble();
    } else if (values[2] is Ratio) {
      seconds = (values[2] as Ratio).toDouble();
    } else if (values[2].toString().contains('/')) {
      // Kesirli saniye değerlerini işle
      final parts = values[2].toString().split('/');
      if (parts.length == 2) {
        final numerator = double.parse(parts[0]);
        final denominator = double.parse(parts[1]);
        seconds = numerator / denominator;
      }
    }

    return degrees + (minutes / 60) + (seconds / 3600);
  }

  Future<void> getPlaceAddress(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        // İlk sonucu al (birden fazla sonuç dönebilir)
        Placemark place = placemarks[0];

        // Tam adresi oluştur
        String address = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
        setAddressText(address);

        print('Adres: $address');
      }
    } catch (e) {
      print('Adres bulunamadı: $e');
    }
  }
  void setAddressText(String? address) {
    setState(() {
      if (address == null || address.trim().isEmpty) {
        _controllerAdres.text = "Konum Bulunamadı";
      } else {
        _controllerAdres.text = address;
      }
    });
  }
  Widget customDividerWithText(String text) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Divider(
          thickness: 2, // Çizgi kalınlığı
        ),
        Container(
          color: Colors.white, // Metin arka plan rengi (Divider üzerindeki metni vurgulamak için)
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0), // Metin etrafındaki boşluk
            child: Text(
              text,
              style: TextStyle(fontWeight: FontWeight.bold), // Metin stili
            ),
          ),
        ),
      ],
    );
  }
  Future<void> removeExifAndSaveNewImage(File imageFile) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          width: MediaQuery.of(context).size.width, // Genişliği ayarlayamayız çünkü bu, ekran genişliğine göre ayarlanır.
          height: MediaQuery.of(context).size.height*0.2, // Yüksekliği burada belirleyebiliriz.
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              CircularProgressIndicator(),
              Text("Lütfen Bekleyin..."),
            ],
          ),
        );
      },
      isScrollControlled: true, // Bu, modalın tam ekran modunda olup olmamasını kontrol eder.
      shape: RoundedRectangleBorder( // Kenarlık şeklini ayarla
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
    );
    await Future.delayed(Duration(seconds: 3));
    final Uint8List originalImageBytes = await imageFile.readAsBytes();
    final img.Image originalImage = img.decodeImage(originalImageBytes)!;
    final img.Image newImage = img.copyResize(originalImage, width: 600); // Örnek olarak yeniden boyutlandırma

    // Yeni resmi PNG formatında kodla
    final List<int> newImageBytes = img.encodePng(newImage);

    // Yeni resmi dosya olarak kaydet
    final directory = await getApplicationDocumentsDirectory();
    final String newPath = '${directory.path}/new_image_no_exif.png';
    final File newImageFile = File(newPath);
    await newImageFile.writeAsBytes(newImageBytes);

    Navigator.of(context).pop(); // Dialog'u kapat

    Share.shareFiles([newPath], text: 'İşlenmiş Görsel');
  }
  void showConfirmationDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Reklamın tamamını izledikten sonra, görsel üzerindeki konum ve diğer bilgiler silinecektir. Açılan pencereden, fotoğrafı istediğiniz kaynağa dışa aktarabilirsiniz.",
                  textAlign: TextAlign.center,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Dialogu kapat
                      // Negatif butona basıldığında yapılacak işlemler
                    },
                    child: Text('İptal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent, // Butonun arka plan rengi
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Dialogu kapat
                      // Pozitif butona basıldığında yapılacak işlemler
                      showRewardedAd();
                    },
                    child: Text('Reklam İzle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent, // Butonun arka plan rengi
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
    );
  }
}

