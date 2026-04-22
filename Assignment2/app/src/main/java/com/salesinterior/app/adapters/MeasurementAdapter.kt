package com.salesinterior.app.adapters

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.salesinterior.app.R
import com.salesinterior.app.data.Measurement

class MeasurementAdapter(
    private var measurements: List<Measurement>,
    private val onSelectProductClick: (Measurement) -> Unit
) : RecyclerView.Adapter<MeasurementAdapter.MeasurementViewHolder>() {

    class MeasurementViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val tvType: TextView = view.findViewById(R.id.tvMeasurementType)
        val tvValues: TextView = view.findViewById(R.id.tvMeasurementValues)
        val btnSelectProduct: Button = view.findViewById(R.id.btnSelectProductForMeasurement)
        val tvSelectedProduct: TextView = view.findViewById(R.id.tvSelectedProductName)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MeasurementViewHolder {
        val view = LayoutInflater.from(parent.context).inflate(R.layout.item_measurement, parent, false)
        return MeasurementViewHolder(view)
    }

    override fun onBindViewHolder(holder: MeasurementViewHolder, position: Int) {
        val m = measurements[position]
        holder.tvType.text = m.type
        
        if (m.type == "WINDOW") {
            holder.tvValues.text = "${m.width} x ${m.height} mm"
        } else {
            holder.tvValues.text = "${m.area} m²"
        }

        if (m.productId.isNotEmpty()) {
            holder.btnSelectProduct.visibility = View.GONE
            holder.tvSelectedProduct.visibility = View.VISIBLE
            holder.tvSelectedProduct.text = "${m.productName} ($${m.productPrice})"
        } else {
            holder.btnSelectProduct.visibility = View.VISIBLE
            holder.tvSelectedProduct.visibility = View.GONE
            holder.btnSelectProduct.setOnClickListener { onSelectProductClick(m) }
        }
    }

    override fun getItemCount() = measurements.size

    fun updateMeasurements(newMeasurements: List<Measurement>) {
        measurements = newMeasurements
        notifyDataSetChanged()
    }
}
