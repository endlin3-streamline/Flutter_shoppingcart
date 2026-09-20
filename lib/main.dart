import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _PageState();
}

// function untuk menampung variable
class _PageState extends State<ProfilePage> {
  bool selected = false;
  bool isNameSelected = false;
  int likes = 0;
  int _selectedIndex = 0; // 0=home, 1=category, 2=cart, 3=account

  int selectedItem = -1;
  List<int> likeCounts = [12, 8, 5, 3];
  List<int> qtys = [1, 1, 1, 0];
  List<bool> isLiked = [false, false, false, false];


  //index untuk bottom navbar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  OverlayEntry? _popupEntry;
  Timer? _popupTimer;

  void _showTopPopup(String name) {
    // remove the previous popup first so they don't stack
    _hideTopPopup();

    _popupEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 8, // below the status bar
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Produk dipilih!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '$name telah dipilih',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _hideTopPopup,
                  child: const Icon(Icons.close, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_popupEntry!);

    // auto-dismiss after 2 seconds
    _popupTimer = Timer(const Duration(seconds: 2), _hideTopPopup);
  }

  void _hideTopPopup() {
    _popupTimer?.cancel();
    _popupEntry?.remove();
    _popupEntry = null;
  }

  @override
  void dispose() {
    _hideTopPopup(); // clean up if the page closes while the popup is showing
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        titleSpacing: 0,

        // icon shopping cart
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.shopping_cart),
          iconSize: 32,
          color: Colors.white,
          //padding: EdgeInsets.only(left: 20),
        ),
        // text + subtext
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
         children: [
           const Text(
             'My Cart', style: TextStyle(color: Colors.white, fontSize: 17),
           ),
           const Text(
             'Belanja lebih mudah setiap hari', style: TextStyle(color: Colors.white, fontSize: 12),
           ),
         ],
        ),
        // icon search
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
            iconSize: 32,
            color: Colors.white,
            //padding: EdgeInsets.only(right: 20),
          ),
        ]
      ),

      // ===========================================================================

      body: Stack(
        children: [
          // layer 1: scrolling items
          ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 100), // room so the last box can scroll above the bar
            children: [
              buildItemPage(context, index: 0, image: 'images/headphone.webp',
                  name: 'Wireless Headphone', brand: 'Sony WH-CH520', price: 'Rp 350.000'),
              buildItemPage(context, index: 1, image: 'images/asuslaptop.webp',
                  name: 'Laptop ASUS Vivobook', brand: 'ASUS', price: 'Rp 7.500.000'),
              buildItemPage(context, index: 2, image: 'images/mouse.webp',
                  name: 'Wireless Mouse', brand: 'Logitech M330', price: 'Rp 250.000'),
              buildItemPage(context, index: 3, image: 'images/earphones.webp',
                  name: 'Wired Earphones', brand: 'Samsung 3.5mm EO-IA500', price: 'Rp 250.000')
            ],
          ),

          // layer 2: checkout bar on top, pinned to the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: buildCheckoutPage(context),
          ),
        ],
      ),

      // ===========================================================================

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), label: 'Kategori'),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('3'),
              backgroundColor: Colors.red,
              child: Icon(Icons.shopping_cart_outlined),
            ),
            label: 'Keranjang',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun')
        ],
      ),
    );
  }

  // ===========================================================================

  Widget buildItemPage(
      BuildContext context, {
        required int index,
        required String image,
        required String name,
        required String brand,
        required String price,
      }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 650;

    // button styles
    final minusStyle = IconButton.styleFrom(
      backgroundColor: Colors.blue.shade50,
      foregroundColor: Colors.blueAccent,
      minimumSize: const Size(28, 28),
      padding: EdgeInsets.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    );
    final plusStyle = IconButton.styleFrom(
      backgroundColor: Colors.blueAccent,
      foregroundColor: Colors.white,
      minimumSize: const Size(28, 28),
      padding: EdgeInsets.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    );

    // ---- the pieces ----
    final productImage = Image.asset(
      image,
      width: isNarrow ? 80 : 120,
      height: isNarrow ? 80 : 120,
    );

    final nameBrandPrice = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: isNarrow ? 14 : 18)),
        Text(brand,
            style: TextStyle(color: Colors.grey, fontSize: isNarrow ? 12 : 14)),
        const SizedBox(height: 4),
        Text(price,
            style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: isNarrow ? 14 : 18)),
      ],
    );

    final likeRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isLiked[index] ? Icons.favorite : Icons.favorite_border,
          color: isLiked[index] ? Colors.red : Colors.black54,
          size: 18,
        ),
        const SizedBox(width: 4),
        Text('${likeCounts[index]}'),
      ],
    );

    final qtyControls = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          style: minusStyle,
          iconSize: 18,
          onPressed: qtys[index] > 0 ? () => setState(() => qtys[index]--) : null,
          icon: const Icon(Icons.remove),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('${qtys[index]}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        IconButton.filled(
          style: plusStyle,
          iconSize: 18,
          onPressed: qtys[index] < 1 ? () => setState(() => qtys[index]++) : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );

    // ---- narrow vs wide layout ----
    final content = isNarrow
        ? Row(
      children: [
        productImage,
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              nameBrandPrice,
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity, // forces the Wrap to take the full width
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: 8,
                  children: [likeRow, qtyControls],
                ),
              ),
            ],
          ),
        ),
      ],
    )
        : Row(
      children: [
        productImage,
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              nameBrandPrice,
              const SizedBox(height: 8),
              likeRow,
            ],
          ),
        ),
        qtyControls, // moves to the far right on wide screens
      ],
    );

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedItem = (selectedItem == index) ? -1 : index;
        });
      },
      onDoubleTap: () {
        setState(() {
          selectedItem = index;
          isLiked[index] = !isLiked[index];
          likeCounts[index] += isLiked[index] ? 1 : -1;
        });
      },
      onLongPress: () {
        _showTopPopup(name);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selectedItem == index ? Colors.blue.shade50 : Colors.white,
          border: Border.all(
            color: selectedItem == index ? Colors.blueAccent : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.5),
              offset: const Offset(0, 3),
              blurRadius: 7,
            ),
          ],
          borderRadius: BorderRadius.circular(12),
        ),
        child: content,
      ),
    );
  }

  // ===========================================================================

  Widget buildCheckoutPage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.5),
            offset: const Offset(0, 3),
            blurRadius: 7,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('Total (3 produk)',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Text('Rp 8.100.000',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent)),
            ],
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 19),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Checkout',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

}