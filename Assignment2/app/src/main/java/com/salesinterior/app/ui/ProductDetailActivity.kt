package com.salesinterior.app.ui

import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.google.firebase.firestore.FirebaseFirestore
import com.salesinterior.app.R
import com.salesinterior.app.data.Product
import com.salesinterior.app.data.Room

class ProductDetailActivity : AppCompatActivity() {

    private lateinit var tvName: TextView
    private lateinit var tvCategory: TextView
    private lateinit var tvPrice: TextView
    private lateinit var tvDescription: TextView
    private lateinit var btnSelect: Button

    private val db = FirebaseFirestore.getInstance()
    private var houseId: String? = null
    private var roomId: String? = null
    private var measurementId: String? = null
    private var productId: String? = null
    private var product: Product? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_product_detail)

        houseId = intent.getStringExtra("HOUSE_ID")
        roomId = intent.getStringExtra("ROOM_ID")
        measurementId = intent.getStringExtra("MEASUREMENT_ID")
        productId = intent.getStringExtra("PRODUCT_ID")

        setupViews()
        fetchProductDetails()
    }

    private fun setupViews() {
        tvName = findViewById(R.id.tvDetailProductName)
        tvCategory = findViewById(R.id.tvDetailProductCategory)
        tvPrice = findViewById(R.id.tvDetailProductPrice)
        tvDescription = findViewById(R.id.tvDetailProductDescription)
        btnSelect = findViewById(R.id.btnSelectProduct)

        btnSelect.setOnClickListener {
            linkProductToMeasurement()
        }
    }

    private fun fetchProductDetails() {
        val pId = productId ?: return
        db.collection("products").document(pId).get()
            .addOnSuccessListener { snapshot ->
                product = snapshot.toObject(Product::class.java)
                product?.let {
                    tvName.text = it.name
                    tvCategory.text = "Category: ${it.category}"
                    tvPrice.text = "$${it.price} per ${if (it.category == "WINDOW") "unit" else "m²"}"
                    tvDescription.text = it.description
                }
            }
    }

    private fun linkProductToMeasurement() {
        val hId = houseId ?: return
        val rId = roomId ?: return
        val mId = measurementId ?: return
        val currentProduct = product ?: return

        val roomRef = db.collection("houses").document(hId).collection("rooms").document(rId)
        
        db.runTransaction { transaction ->
            val snapshot = transaction.get(roomRef)
            val room = snapshot.toObject(Room::class.java) ?: return@runTransaction
            
            val updatedMeasurements = room.measurements.map { m ->
                if (m.id == mId) {
                    m.copy(
                        productId = currentProduct.id,
                        productName = currentProduct.name,
                        productPrice = currentProduct.price
                    )
                } else {
                    m
                }
            }
            
            transaction.update(roomRef, "measurements", updatedMeasurements)
        }.addOnSuccessListener {
            Toast.makeText(this, "Product linked successfully", Toast.LENGTH_SHORT).show()
            val intent = Intent(this, HouseListActivity::class.java)
            intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP
            startActivity(intent)
        }.addOnFailureListener {
            Toast.makeText(this, "Error linking product", Toast.LENGTH_SHORT).show()
        }
    }
}
