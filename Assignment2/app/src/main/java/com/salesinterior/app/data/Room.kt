package com.salesinterior.app.data

import com.google.firebase.firestore.IgnoreExtraProperties

@IgnoreExtraProperties
data class Room(
    val id: String = "",
    val name: String = "", // e.g., "Living Room"
    val measurements: List<Measurement> = emptyList()
)
