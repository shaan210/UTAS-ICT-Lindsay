package com.salesinterior.app.data

import com.google.firebase.firestore.IgnoreExtraProperties

@IgnoreExtraProperties
data class Product(
    val id: String = "",
    val name: String = "",
    val description: String = "",
    val category: String = "", // e.g., "Wood", "Carpet", "Tiles"
    val price: Double = 0.0
)
