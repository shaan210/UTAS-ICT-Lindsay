package com.salesinterior.app.data

import com.google.firebase.firestore.IgnoreExtraProperties

@IgnoreExtraProperties
data class House(
    val id: String = "",
    val clientName: String = "",
    val projectCode: String = "",
    val street: String = "",
    val city: String = "",
    val postcode: String = ""
)
