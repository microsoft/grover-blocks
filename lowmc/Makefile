# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.
all: affine_layers key_expansion

affine_layers:
	sage affine_layers.py

key_expansion:
	sage in_place_round_key_generation.py

clean_affine:
	rm affine_layers_L*

clean_key_exp:
	rm in_place_key_expansion_L*
	rm in_place_km_L*

clean:	clean_affine clean_key_exp
