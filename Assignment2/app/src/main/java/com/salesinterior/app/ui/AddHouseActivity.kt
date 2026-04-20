package com.salesinterior.app.ui

import android.os.Bundle
import android.widget.Button
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.google.android.material.textfield.TextInputEditText
import com.google.firebase.firestore.FirebaseFirestore
import com.salesinterior.app.R
import com.salesinterior.app.data.House

class AddHouseActivity : AppCompatActivity() {

    private lateinit var etClientName: TextInputEditText
    private lateinit var etProjectCode: TextInputEditText
    private lateinit var etStreet: TextInputEditText
    private lateinit var etCity: TextInputEditText
    private lateinit var etPostcode: TextInputEditText
    private lateinit var btnSaveHouse: Button
    private lateinit var btnCancel: Button

    private val db = FirebaseFirestore.getInstance()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_add_house)

        setupViews()
    }

    private fun setupViews() {
        etClientName = findViewById(R.id.etClientName)
        etProjectCode = findViewById(R.id.etProjectCode)
        etStreet = findViewById(R.id.etStreet)
        etCity = findViewById(R.id.etCity)
        etPostcode = findViewById(R.id.etPostcode)
        btnSaveHouse = findViewById(R.id.btnSaveHouse)
        btnCancel = findViewById(R.id.btnCancel)

        btnSaveHouse.setOnClickListener {
            validateAndSave()
        }

        btnCancel.setOnClickListener {
            finish()
        }
    }

    private fun validateAndSave() {
        val clientName = etClientName.text.toString().trim()
        val projectCode = etProjectCode.text.toString().trim()
        val street = etStreet.text.toString().trim()
        val city = etCity.text.toString().trim()
        val postcode = etPostcode.text.toString().trim()

        var isValid = true

        if (clientName.isEmpty()) {
            etClientName.error = "Field cannot be empty"
            isValid = false
        }
        if (projectCode.isEmpty()) {
            etProjectCode.error = "Field cannot be empty"
            isValid = false
        }
        if (street.isEmpty()) {
            etStreet.error = "Field cannot be empty"
            isValid = false
        }
        if (city.isEmpty()) {
            etCity.error = "Field cannot be empty"
            isValid = false
        }
        if (postcode.isEmpty()) {
            etPostcode.error = "Field cannot be empty"
            isValid = false
        }

        if (!isValid) return

        // Create House object
        val houseRef = db.collection("houses").document()
        val house = House(
            id = houseRef.id,
            clientName = clientName,
            projectCode = projectCode,
            street = street,
            city = city,
            postcode = postcode
        )

        houseRef.set(house)
            .addOnSuccessListener {
                Toast.makeText(this, "House saved successfully", Toast.LENGTH_SHORT).show()
                finish()
            }
            .addOnFailureListener { e ->
                Toast.makeText(this, "Error saving house: ${e.message}", Toast.LENGTH_SHORT).show()
            }
    }
}
