import LoopKitUI
import SwiftUI

struct PairingView: View {
    @ObservedObject var viewModel: PairingViewModel

    var body: some View {
        VStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Spacer()
                            Image(imageName: "sensor")
                                .resizable()
                                .scaledToFit()
                                .padding(.horizontal)
                                .frame(height: 150)
                                .padding(.bottom, 20)
                            Spacer()
                        }

                        Text("Please be patient", comment: "pairing header")
                            .font(.title3)
                            .bold()

                        Text(
                            "It might take up to a full minute before the pairing is completed. Make sure to keep the twist cap till the pairing is complete.",
                            comment: "pairing body"
                        )
                    }
                }
            }
            Spacer()

            VStack(spacing: 5) {
                ActivityIndicator(isAnimating: .constant(true), style: .medium)
                Text("Pairing with CGM", comment: "pairing footer")
                    .font(.footnote)
            }
        }
        .alert(isPresented: $viewModel.modelUnsupported) {
            Alert(
                title: Text("Warning: Untested device"),
                message: Text("This is a untested device model. Please be careful! Share any issues with Trio discord"),
                dismissButton: .default(Text("I understand")) {
                   viewModel.nextStep()
               }
            )
        }
    }
}
