import 'package:flutter/material.dart';

import '../pages/detail_mua_page.dart';

class MuaCard extends StatelessWidget {

  final String name;
  final String location;
  final String price;

  const MuaCard({
    super.key,
    required this.name,
    required this.location,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      width: 135,

      margin: const EdgeInsets.only(right: 12),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        boxShadow: [

          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),

        ],
      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          // IMAGE
          Container(

            height: 85,

            decoration: BoxDecoration(

              color: Colors.pink[100],

              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),

            child: const Center(

              child: Icon(
                Icons.face_retouching_natural,
                size: 38,
                color: Colors.black87,
              ),

            ),
          ),

          Expanded(

            child: Padding(

              padding: const EdgeInsets.all(8),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(

                    name,

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Row(

                    children: [

                      Icon(
                        Icons.location_on,
                        size: 11,
                        color: Colors.grey[600],
                      ),

                      const SizedBox(width: 2),

                      Expanded(

                        child: Text(

                          location,

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,

                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 9,
                          ),
                        ),
                      ),

                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(

                    price,

                    style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),

                  const Spacer(),

                  SizedBox(

                    width: double.infinity,
                    height: 30,

                    child: ElevatedButton(

                      onPressed: () {

                        Navigator.push(

                          context,

                          MaterialPageRoute(
                            builder: (context) =>
                                const DetailMuaPage(),
                          ),

                        );

                      },

                      style: ElevatedButton.styleFrom(

                        backgroundColor:
                            const Color(0xFFD4AF37),

                        elevation: 0,

                        padding: EdgeInsets.zero,

                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                      ),

                      child: const Text(

                        "Detail",

                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}