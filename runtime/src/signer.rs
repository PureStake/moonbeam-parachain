

use sp_core::{H160, H256, ecdsa, ed25519, sr25519, RuntimeDebug};
use codec::{Decode, Encode, Input, Output, Error};
use sha3::{Digest, Keccak256};

#[cfg(feature = "std")]
pub use serde::{Serialize, Deserialize, de::DeserializeOwned};

#[cfg_attr(feature = "std", derive(serde::Serialize, serde::Deserialize))]
#[derive(Eq, PartialEq, Clone, Encode, Decode, sp_core::RuntimeDebug)]
pub struct EthereumSignature(ecdsa::Signature);

impl From<ecdsa::Signature> for EthereumSignature {
	fn from(x: ecdsa::Signature) -> Self {
		EthereumSignature(x)
	}
}

#[cfg_attr(feature = "std", derive(Serialize, Deserialize))]
#[derive(Eq, PartialEq, Clone, Encode, Decode, RuntimeDebug)]
pub enum MultiSignature {
	Ed25519(ed25519::Signature),
	Sr25519(sr25519::Signature),
	Ecdsa(EthereumSignature),
}

impl From<EthereumSignature> for MultiSignature {
	fn from(x: EthereumSignature) -> Self {
		MultiSignature::Ecdsa(x)
	}
}

impl sp_runtime::traits::Verify for MultiSignature {
	type Signer = EthereumSigner;
	fn verify<L: sp_runtime::traits::Lazy<[u8]>>(&self, mut msg: L, signer: &super::account::AccountId20) -> bool {
		match (self, signer) {
			(MultiSignature::Ecdsa(ref sig), who) => {
				let mut m = [0u8; 32];
				m.copy_from_slice(Keccak256::digest(msg.get()).as_slice());
				match sp_io::crypto::secp256k1_ecdsa_recover(sig.0.as_ref(), &m) {
					Ok(pubkey) => {
						let mut value = [0u8; 20];
						value.copy_from_slice(&H160::from(H256::from_slice(Keccak256::digest(&pubkey).as_slice()))[..]);
						&value == <dyn AsRef<[u8; 20]>>::as_ref(who)
					},
					Err(sp_io::EcdsaVerifyError::BadRS) => {
						log::error!(target: "evm", "Error recovering: Incorrect value of R or S");
						false
					},
					Err(sp_io::EcdsaVerifyError::BadV) => {
						log::error!(target: "evm", "Error recovering: Incorrect value of V");
						false
					},
					Err(sp_io::EcdsaVerifyError::BadSignature) => {
						log::error!(target: "evm", "Error recovering: Invalid signature");
						false
					}
				}
			},
			_ => false
		}
	}
}


/// Public key for any known crypto algorithm.
#[derive(Eq, PartialEq, Ord, PartialOrd, Clone, Encode, sp_core::RuntimeDebug)]
#[cfg_attr(feature = "std", derive(serde::Serialize, serde::Deserialize))]
pub struct EthereumSigner ([u8; 20]);

impl Decode for EthereumSigner {
	fn decode<I: Input>(input: &mut I) -> Result<Self, codec::Error> {
		match H160::decode(input) {
			Ok(h) => {
				log::info!(target: "evm", "Decoding H160: {:?}", h);
				Err(codec::Error::from("OK !!"))
			},
			Err(e) => {
				log::info!(target: "evm", "Failed decoding H160");
				Err(e)
			}
		}
	}
}

impl sp_runtime::traits::IdentifyAccount for EthereumSigner {
	type AccountId = super::account::AccountId20;
	fn into_account(self) -> super::account::AccountId20 {
		self.0.into()
	}
}

impl sp_core::crypto::UncheckedFrom<[u8; 20]> for EthereumSigner {
	fn unchecked_from(x: [u8; 20]) -> Self {
		EthereumSigner(x)
	}
}

impl From<[u8; 20]> for EthereumSigner {
	fn from(x: [u8; 20]) -> Self {
		EthereumSigner(x)
	}
}


impl From<ecdsa::Public> for EthereumSigner {
	fn from(x: ecdsa::Public) -> Self {
		let mut m = [0u8; 20];
		m.copy_from_slice(&x.as_ref()[13..33]);
		EthereumSigner(m)
	}
}

#[cfg(feature = "std")]
impl std::fmt::Display for EthereumSigner {
	fn fmt(&self, fmt: &mut std::fmt::Formatter) -> std::fmt::Result {
		write!(fmt, "ethereum signature: {:?}", H160::from_slice(&self.0))
	}
}
