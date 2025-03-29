import "package:flutter/material.dart";
import "package:cached_network_image/cached_network_image.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:dont_feed_donald/data/models/brand_search_result.dart";
import "package:dont_feed_donald/data/repositories/brand_repository.dart";
import "package:dont_feed_donald/domain/blocs/brand_literacy/brand_literacy_bloc.dart";
import "package:dont_feed_donald/domain/blocs/brand_literacy/brand_literacy_event.dart";
import "package:dont_feed_donald/domain/blocs/brand_literacy/brand_literacy_state.dart";
import "package:dont_feed_donald/domain/entities/brand_literacy.dart";

class BrandDetailsPage extends StatelessWidget {
  final BrandSearchResult searchResult;

  const BrandDetailsPage({
    super.key,
    required this.searchResult,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BrandLiteracyBloc(
        brandRepository: BrandRepository(),
      )..add(FetchBrandLiteracy(brandId: searchResult.id)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(searchResult.name),
        ),
        body: BlocBuilder<BrandLiteracyBloc, BrandLiteracyState>(
          builder: (context, state) {
            switch (state.status) {
              case BrandLiteracyStatus.initial:
              case BrandLiteracyStatus.loading:
                return const Center(
                  child: CircularProgressIndicator(),
                );
              case BrandLiteracyStatus.loaded:
                return _buildBrandLiteracyDetails(context, state.brandLiteracy!);
              case BrandLiteracyStatus.error:
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: ${state.errorMessage}', 
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<BrandLiteracyBloc>()
                            .add(FetchBrandLiteracy(brandId: searchResult.id));
                        },
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                );
            }
          },
        ),
      ),
    );
  }
  
  Widget _buildBrandLiteracyDetails(BuildContext context, BrandLiteracy brandLiteracy) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo at the top if available
          if (brandLiteracy.logoUrl != null && brandLiteracy.logoUrl!.isNotEmpty)
            Center(
              child: SizedBox(
                height: 150,
                child: CachedNetworkImage(
                  imageUrl: brandLiteracy.logoUrl!,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, size: 60),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          const SizedBox(height: 24),
          
          // Brand name as title
          Center(
            child: Text(
              brandLiteracy.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          
          // Display all fields in a simple column layout
          Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Brand Details",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  _buildInfoRow("ID", brandLiteracy.id),
                  _buildInfoRow("Name", brandLiteracy.name),
                  _buildInfoRow("Brand Origin", brandLiteracy.brandOrigin),
                  _buildInfoRow("Parent Company", brandLiteracy.parentCompany),
                  _buildInfoRow("Product Family", brandLiteracy.productFamily),
                  _buildInfoRow("Logo URL", brandLiteracy.logoUrl),
                  _buildInfoRow("Similar Brands EU", brandLiteracy.similarBrandsEu),
                  _buildInfoRow("Total Employees", brandLiteracy.totalEmployees),
                  _buildInfoRow("Total Employees Source", brandLiteracy.totalEmployeesSource),
                  _buildInfoRow("Employees US", brandLiteracy.employeesUS),
                  _buildInfoRow("Employees US Source", brandLiteracy.employeesUSSource),
                  _buildInfoRow("Economic Impact", brandLiteracy.economicImpact),
                  _buildInfoRow("Economic Impact Source", brandLiteracy.economicImpactSource),
                  _buildInfoRow("Factory in France", brandLiteracy.factoryInFrance?.toString()),
                  _buildInfoRow("Factory in France Source", brandLiteracy.factoryInFranceSource),
                  _buildInfoRow("Factory in EU", brandLiteracy.factoryInEU?.toString()),
                  _buildInfoRow("Factory in EU Source", brandLiteracy.factoryInEUSource),
                  _buildInfoRow("French Farmer", brandLiteracy.frenchFarmer?.toString()),
                  _buildInfoRow("French Farmer Source", brandLiteracy.frenchFarmerSource),
                  _buildInfoRow("EU Farmer", brandLiteracy.euFarmer?.toString()),
                  _buildInfoRow("EU Farmer Source", brandLiteracy.euFarmerSource),
                  _buildInfoRow("Created At", brandLiteracy.createdAt?.toString()),
                  _buildInfoRow("Updated At", brandLiteracy.updatedAt?.toString()),
                  _buildInfoRow("Is Enabled", brandLiteracy.isEnabled?.toString()),
                  _buildInfoRow("Is Error", brandLiteracy.isError?.toString()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  

  
  Widget _buildInfoRow(String label, dynamic value) {
    if (value == null) {
      return const SizedBox.shrink(); // Don't display empty values
    }
    
    String displayValue;
    if (value is List<String>) {
      displayValue = value.join(', ');
      if (displayValue.isEmpty) {
        return const SizedBox.shrink();
      }
    } else {
      displayValue = value.toString();
      if (displayValue.isEmpty) {
        return const SizedBox.shrink();
      }
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(displayValue),
            ),
          ),
        ],
      ),
    );
  }
}
