package com.salesinterior.app.ui

import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.google.firebase.firestore.FirebaseFirestore
import com.salesinterior.app.R
import com.salesinterior.app.adapters.ProductAdapter
import com.salesinterior.app.data.Product

class ProductListActivity : AppCompatActivity() {

    private lateinit var rvProducts: RecyclerView
    private lateinit var productAdapter: ProductAdapter
    private val db = FirebaseFirestore.getInstance()

    private var houseId: String? = null
    private var roomId: String? = null
    private var measurementId: String? = null
    private var categoryFilter: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_product_list)

        houseId = intent.getStringExtra("HOUSE_ID")
        roomId = intent.getStringExtra("ROOM_ID")
        measurementId = intent.getStringExtra("MEASUREMENT_ID")
        categoryFilter = intent.getStringExtra("CATEGORY_FILTER") // e.g. "WINDOW" or "FLOOR_SPACE"

        setupRecyclerView()
        fetchProducts()
    }

    private fun setupRecyclerView() {
        rvProducts = findViewById(R.id.rvProducts)
        productAdapter = ProductAdapter(emptyList()) { product ->
            val intent = Intent(this, ProductDetailActivity::class.java)
            intent.putExtra("HOUSE_ID", houseId)
            intent.putExtra("ROOM_ID", roomId)
            intent.putExtra("MEASUREMENT_ID", measurementId)
            intent.putExtra("PRODUCT_ID", product.id)
            startActivity(intent)
        }
        rvProducts.layoutManager = LinearLayoutManager(this)
        rvProducts.adapter = productAdapter
    }

    private fun fetchProducts() {
        var query = db.collection("products").limit(50)
        
        // Optionally filter by category if needed
        // if (categoryFilter != null) {
        //     query = query.whereEqualTo("category", categoryFilter)
        // }

        query.get()
            .addOnSuccessListener { snapshot ->
                val products = snapshot.toObjects(Product::class.java)
                if (products.isEmpty()) {
                    seedInitialProducts()
                } else {
                    productAdapter.updateProducts(products)
                }
            }
            .addOnFailureListener {
                Toast.makeText(this, "Error fetching products", Toast.LENGTH_SHORT).show()
            }
    }

    private fun seedInitialProducts() {
        val initialProducts = listOf(
            Product("p1", "Premium Hardwood", "WOOD", "High-quality oak flooring", 45.0),
            Product("p2", "Durable Vinyl", "VINYL", "Waterproof flooring for kitchens", 25.0),
            Product("p3", "Double-Pane Glass", "WINDOW", "Energy-efficient window solution", 150.0),
            Product("p4", "Single-Pane Glass", "WINDOW", "Standard replacement glass", 85.0)
        )

        val batch = db.batch()
        for (product in initialProducts) {
            val docRef = db.collection("products").document(product.id)
            batch.set(docRef, product)
        }

        batch.commit().addOnSuccessListener {
            fetchProducts()
        }
    }
}
