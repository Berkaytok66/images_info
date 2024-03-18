
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:images_info/Page/InfoPage.dart';
import 'package:pushable_button/pushable_button.dart';

class SelectFile extends StatefulWidget {
  const SelectFile({Key? key}) : super(key: key);

  @override
  State<SelectFile> createState() => _SelectFileState();
}

class _SelectFileState extends State<SelectFile> {
  var heightEkran;
  var widthEkran;
  late RewardedAd myRewardedAd;
  bool isAdLoaded = false;
  XFile? image;
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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadRewardedAd();
  }

  void showRewardedAd() {
    if (isAdLoaded) {
      myRewardedAd.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          // Ödüllü reklam izlendikten sonra yapılacak işlemler
         // pickImageFromGallery();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InfoPage(image: image!)),
          );

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
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => InfoPage(image: image!)),
      );
     // pickImageFromGallery();
    }
  }


  Future<void> pickImageFromGallery() async {
    image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      showRewardedAd();


    }
  }
  @override
  Widget build(BuildContext context) {
    heightEkran = MediaQuery.of(context).size.height;
    widthEkran = MediaQuery.of(context).size.width;
    return Scaffold(
      // Stack widget'ı ile içerikleri üst üste yerleştirelim.
      body: Stack(
        children: <Widget>[
          // Arka plan resmi
          Positioned.fill(
            child: Image.asset(
              'images/page_one_image.png', // Gerçek bir resim URL'si ile değiştirin
              fit: BoxFit.cover, // Resmi ekranın boyutuna sığdırmak için
            ),
          ),
          // Card widget'ı
          Align(
            alignment: Alignment.bottomCenter, // Card'ı altta ortaya hizala
            child: ClipRRect(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(124.0)), // Üst sol köşeyi kıvrımlı yap
              child: Container(
                color: Colors.white,
                height: MediaQuery.of(context).size.height * 0.4, // Yüksekliği ekranın %40'ı yap
                width: double.infinity, // Genişliği tam ekran yap
                padding: EdgeInsets.all(16.0), // İçerik için padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'Başlık',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30), // Başlık ile açıklama arasında boşluk
                    const Text(
                      textAlign: TextAlign.center,
                      'Fotoğrafların bilgileri her zaman görünmeyebilir; bu, çekim yapılan cihazın bu bilgileri kaydetmemesi, fotoğrafın düzenlenmesi ya da paylaşım sırasında bilgilerin silinmesi gibi nedenlerden olabilir.',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: heightEkran /15),
                    Container(
                        width:200,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Butona basıldığında yapılacak işlem
                            //  showRewardedAd();
                            showConfirmationDialog();
                          },
                          icon: Icon(
                            Icons.image, // Burada kendi ikonunuzu kullanabilirsiniz.
                            color: Colors.white, // İkonun rengi
                          ),
                          label: Text(
                            'Fotograf Seç', // Butonun metni
                            style: TextStyle(
                              color: Colors.black, // Metin rengi
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.purple, backgroundColor: Colors.grey[350], // Basılı tutulduğunda olan renk
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0), // Butonun köşe yuvarlaklığı
                            ),
                          ),
                        )

                    )

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
                  "İşleme devam etmek için reklamın tamamını izleyin ardından resim seçmek için yönlendirileceksiniz.",
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

                      pickImageFromGallery();
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
