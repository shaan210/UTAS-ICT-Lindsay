package com.salesinterior.app.data

import com.google.firebase.firestore.IgnoreExtraProperties

@IgnoreExtraProperties
data class Measurement(
    val id: String = java.util.UUID.randomUUID().toString(),
    val type: String = "WINDOW", // "WINDOW" or "FLOOR_SPACE"
    val width: Double? = null,
    val height: Double? = null,
    val area: Double? = null,
    val productId: String = "",
    val productName: String = "",
    val productPrice: Double = 0.0
) {
    fun isValid(): Boolean {
        return when (type) {
            "WINDOW" -> (width ?: 0.0) > 0 && (height ?: 0.0) > 0
            "FLOOR_SPACE" -> (area ?: 0.0) > 0
            else -> false
        }
    }
}
